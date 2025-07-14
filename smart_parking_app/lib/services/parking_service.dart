import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/parking_spot_model.dart';
import '../models/reservation_model.dart';
import '../config/firebase_config.dart';

class ParkingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all parking spots
  Stream<List<ParkingSpotModel>> getAllParkingSpots() {
    return _firestore
        .collection(FirestoreCollections.parkingSpots)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ParkingSpotModel.fromMap({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  // Get parking spots by location (within radius)
  Future<List<ParkingSpotModel>> getParkingSpotsNearby({
    required double latitude,
    required double longitude,
    double radiusInKm = 5.0,
  }) async {
    try {
      // Get all parking spots first (in a real app, you'd use geohash for efficiency)
      QuerySnapshot snapshot = await _firestore
          .collection(FirestoreCollections.parkingSpots)
          .get();

      List<ParkingSpotModel> nearbySpots = [];

      for (var doc in snapshot.docs) {
        final spot = ParkingSpotModel.fromMap({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });

        // Calculate distance
        double distance = Geolocator.distanceBetween(
          latitude,
          longitude,
          spot.location.latitude,
          spot.location.longitude,
        ) / 1000; // Convert to kilometers

        if (distance <= radiusInKm) {
          nearbySpots.add(spot);
        }
      }

      // Sort by distance
      nearbySpots.sort((a, b) {
        double distanceA = Geolocator.distanceBetween(
          latitude,
          longitude,
          a.location.latitude,
          a.location.longitude,
        );
        double distanceB = Geolocator.distanceBetween(
          latitude,
          longitude,
          b.location.latitude,
          b.location.longitude,
        );
        return distanceA.compareTo(distanceB);
      });

      return nearbySpots;
    } catch (e) {
      throw Exception('Failed to get nearby parking spots: $e');
    }
  }

  // Get parking spot by ID
  Future<ParkingSpotModel?> getParkingSpotById(String spotId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(FirestoreCollections.parkingSpots)
          .doc(spotId)
          .get();

      if (doc.exists) {
        return ParkingSpotModel.fromMap({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get parking spot: $e');
    }
  }

  // Search parking spots
  Future<List<ParkingSpotModel>> searchParkingSpots({
    String? query,
    ParkingSpotType? type,
    double? maxPrice,
    List<String>? features,
  }) async {
    try {
      Query queryRef = _firestore.collection(FirestoreCollections.parkingSpots);

      // Apply filters
      if (type != null) {
        queryRef = queryRef.where('type', isEqualTo: type.toString().split('.').last);
      }

      if (maxPrice != null) {
        queryRef = queryRef.where('pricePerHour', isLessThanOrEqualTo: maxPrice);
      }

      QuerySnapshot snapshot = await queryRef.get();
      List<ParkingSpotModel> spots = snapshot.docs
          .map((doc) => ParkingSpotModel.fromMap({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();

      // Apply text search filter
      if (query != null && query.isNotEmpty) {
        spots = spots.where((spot) =>
            spot.name.toLowerCase().contains(query.toLowerCase()) ||
            spot.address.toLowerCase().contains(query.toLowerCase()) ||
            spot.zone.toLowerCase().contains(query.toLowerCase())).toList();
      }

      // Apply features filter
      if (features != null && features.isNotEmpty) {
        spots = spots.where((spot) =>
            features.every((feature) => spot.features.contains(feature))).toList();
      }

      return spots;
    } catch (e) {
      throw Exception('Failed to search parking spots: $e');
    }
  }

  // Create parking spot (admin only)
  Future<String> createParkingSpot(ParkingSpotModel spot) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(FirestoreCollections.parkingSpots)
          .add(spot.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create parking spot: $e');
    }
  }

  // Update parking spot
  Future<void> updateParkingSpot(ParkingSpotModel spot) async {
    try {
      await _firestore
          .collection(FirestoreCollections.parkingSpots)
          .doc(spot.id)
          .update(spot.copyWith(updatedAt: DateTime.now()).toMap());
    } catch (e) {
      throw Exception('Failed to update parking spot: $e');
    }
  }

  // Delete parking spot
  Future<void> deleteParkingSpot(String spotId) async {
    try {
      await _firestore
          .collection(FirestoreCollections.parkingSpots)
          .doc(spotId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete parking spot: $e');
    }
  }

  // Update parking spot availability
  Future<void> updateParkingAvailability({
    required String spotId,
    required int availableSpots,
  }) async {
    try {
      await _firestore
          .collection(FirestoreCollections.parkingSpots)
          .doc(spotId)
          .update({
        'availableSpots': availableSpots,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update parking availability: $e');
    }
  }

  // Get parking spots with real-time availability
  Stream<List<ParkingSpotModel>> getAvailableParkingSpots() {
    return _firestore
        .collection(FirestoreCollections.parkingSpots)
        .where('status', isEqualTo: 'available')
        .where('availableSpots', isGreaterThan: 0)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ParkingSpotModel.fromMap({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  // Get parking statistics
  Future<Map<String, dynamic>> getParkingStatistics() async {
    try {
      QuerySnapshot spotsSnapshot = await _firestore
          .collection(FirestoreCollections.parkingSpots)
          .get();

      QuerySnapshot reservationsSnapshot = await _firestore
          .collection(FirestoreCollections.reservations)
          .get();

      int totalSpots = spotsSnapshot.docs.length;
      int totalReservations = reservationsSnapshot.docs.length;
      
      int availableSpots = 0;
      int occupiedSpots = 0;

      for (var doc in spotsSnapshot.docs) {
        final spot = ParkingSpotModel.fromMap({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });
        
        if (spot.isAvailable) {
          availableSpots += spot.availableSpots;
        }
        occupiedSpots += (spot.totalSpots - spot.availableSpots);
      }

      return {
        'totalSpots': totalSpots,
        'availableSpots': availableSpots,
        'occupiedSpots': occupiedSpots,
        'totalReservations': totalReservations,
        'occupancyRate': totalSpots > 0 ? (occupiedSpots / totalSpots) : 0.0,
      };
    } catch (e) {
      throw Exception('Failed to get parking statistics: $e');
    }
  }
}
