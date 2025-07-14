import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reservation_model.dart';
import '../config/firebase_config.dart';

class ReservationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new reservation
  Future<String> createReservation(ReservationModel reservation) async {
    try {
      // Check if parking spot is available for the requested time
      bool isAvailable = await _checkAvailability(
        reservation.parkingSpotId,
        reservation.startTime,
        reservation.endTime,
      );

      if (!isAvailable) {
        throw Exception('Parking spot is not available for the selected time');
      }

      // Create reservation
      DocumentReference docRef = await _firestore
          .collection(FirestoreCollections.reservations)
          .add(reservation.toMap());

      // Update parking spot availability
      await _updateParkingSpotAvailability(
        reservation.parkingSpotId,
        -1, // Decrease available spots
      );

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create reservation: $e');
    }
  }

  // Get user reservations
  Stream<List<ReservationModel>> getUserReservations(String userId) {
    return _firestore
        .collection(FirestoreCollections.reservations)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReservationModel.fromMap({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  // Get reservation by ID
  Future<ReservationModel?> getReservationById(String reservationId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(FirestoreCollections.reservations)
          .doc(reservationId)
          .get();

      if (doc.exists) {
        return ReservationModel.fromMap({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get reservation: $e');
    }
  }

  // Update reservation
  Future<void> updateReservation(ReservationModel reservation) async {
    try {
      await _firestore
          .collection(FirestoreCollections.reservations)
          .doc(reservation.id)
          .update(reservation.copyWith(updatedAt: DateTime.now()).toMap());
    } catch (e) {
      throw Exception('Failed to update reservation: $e');
    }
  }

  // Cancel reservation
  Future<void> cancelReservation(String reservationId) async {
    try {
      final reservation = await getReservationById(reservationId);
      if (reservation == null) {
        throw Exception('Reservation not found');
      }

      if (!reservation.canBeCancelled) {
        throw Exception('Reservation cannot be cancelled');
      }

      // Update reservation status
      await _firestore
          .collection(FirestoreCollections.reservations)
          .doc(reservationId)
          .update({
        'status': ReservationStatus.cancelled.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Update parking spot availability
      await _updateParkingSpotAvailability(
        reservation.parkingSpotId,
        1, // Increase available spots
      );
    } catch (e) {
      throw Exception('Failed to cancel reservation: $e');
    }
  }

  // Get active reservations
  Stream<List<ReservationModel>> getActiveReservations(String userId) {
    return _firestore
        .collection(FirestoreCollections.reservations)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'confirmed')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReservationModel.fromMap({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .where((reservation) => reservation.isActive || reservation.isUpcoming)
            .toList());
  }

  // Get upcoming reservations
  Future<List<ReservationModel>> getUpcomingReservations(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(FirestoreCollections.reservations)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'confirmed')
          .where('startTime', isGreaterThan: DateTime.now().toIso8601String())
          .orderBy('startTime')
          .get();

      return snapshot.docs
          .map((doc) => ReservationModel.fromMap({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get upcoming reservations: $e');
    }
  }

  // Get past reservations
  Future<List<ReservationModel>> getPastReservations(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(FirestoreCollections.reservations)
          .where('userId', isEqualTo: userId)
          .where('endTime', isLessThan: DateTime.now().toIso8601String())
          .orderBy('endTime', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReservationModel.fromMap({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get past reservations: $e');
    }
  }

  // Check parking spot availability
  Future<bool> _checkAvailability(
    String parkingSpotId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      // Get overlapping reservations
      QuerySnapshot snapshot = await _firestore
          .collection(FirestoreCollections.reservations)
          .where('parkingSpotId', isEqualTo: parkingSpotId)
          .where('status', whereIn: ['confirmed', 'active'])
          .get();

      for (var doc in snapshot.docs) {
        final reservation = ReservationModel.fromMap({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });

        // Check for time overlap
        if (_hasTimeOverlap(
          startTime,
          endTime,
          reservation.startTime,
          reservation.endTime,
        )) {
          return false;
        }
      }

      return true;
    } catch (e) {
      throw Exception('Failed to check availability: $e');
    }
  }

  // Check if two time periods overlap
  bool _hasTimeOverlap(
    DateTime start1,
    DateTime end1,
    DateTime start2,
    DateTime end2,
  ) {
    return start1.isBefore(end2) && end1.isAfter(start2);
  }

  // Update parking spot availability
  Future<void> _updateParkingSpotAvailability(
    String parkingSpotId,
    int change,
  ) async {
    try {
      DocumentReference spotRef = _firestore
          .collection(FirestoreCollections.parkingSpots)
          .doc(parkingSpotId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot spotSnapshot = await transaction.get(spotRef);
        
        if (!spotSnapshot.exists) {
          throw Exception('Parking spot not found');
        }

        Map<String, dynamic> spotData = spotSnapshot.data() as Map<String, dynamic>;
        int currentAvailable = spotData['availableSpots'] ?? 0;
        int newAvailable = currentAvailable + change;

        // Ensure available spots doesn't go below 0 or above total spots
        int totalSpots = spotData['totalSpots'] ?? 1;
        newAvailable = newAvailable.clamp(0, totalSpots);

        transaction.update(spotRef, {
          'availableSpots': newAvailable,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      });
    } catch (e) {
      throw Exception('Failed to update parking spot availability: $e');
    }
  }

  // Get reservation statistics
  Future<Map<String, dynamic>> getReservationStatistics(String userId) async {
    try {
      QuerySnapshot allReservations = await _firestore
          .collection(FirestoreCollections.reservations)
          .where('userId', isEqualTo: userId)
          .get();

      int totalReservations = allReservations.docs.length;
      int completedReservations = 0;
      int cancelledReservations = 0;
      int activeReservations = 0;
      double totalSpent = 0.0;

      for (var doc in allReservations.docs) {
        final reservation = ReservationModel.fromMap({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });

        switch (reservation.status) {
          case ReservationStatus.completed:
            completedReservations++;
            totalSpent += reservation.totalAmount;
            break;
          case ReservationStatus.cancelled:
            cancelledReservations++;
            break;
          case ReservationStatus.confirmed:
          case ReservationStatus.active:
            activeReservations++;
            break;
          default:
            break;
        }
      }

      return {
        'totalReservations': totalReservations,
        'completedReservations': completedReservations,
        'cancelledReservations': cancelledReservations,
        'activeReservations': activeReservations,
        'totalSpent': totalSpent,
        'averageSpent': totalReservations > 0 ? totalSpent / totalReservations : 0.0,
      };
    } catch (e) {
      throw Exception('Failed to get reservation statistics: $e');
    }
  }

  // Extend reservation
  Future<void> extendReservation({
    required String reservationId,
    required DateTime newEndTime,
    required double additionalAmount,
  }) async {
    try {
      final reservation = await getReservationById(reservationId);
      if (reservation == null) {
        throw Exception('Reservation not found');
      }

      // Check if extension is possible
      bool isAvailable = await _checkAvailability(
        reservation.parkingSpotId,
        reservation.endTime,
        newEndTime,
      );

      if (!isAvailable) {
        throw Exception('Cannot extend reservation - time slot not available');
      }

      // Update reservation
      await _firestore
          .collection(FirestoreCollections.reservations)
          .doc(reservationId)
          .update({
        'endTime': newEndTime.toIso8601String(),
        'totalAmount': reservation.totalAmount + additionalAmount,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to extend reservation: $e');
    }
  }
}
