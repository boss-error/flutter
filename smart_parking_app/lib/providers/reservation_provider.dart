import 'package:flutter/material.dart';
import '../models/reservation_model.dart';
import '../services/reservation_service.dart';

class ReservationProvider with ChangeNotifier {
  final ReservationService _reservationService = ReservationService();
  
  List<ReservationModel> _reservations = [];
  List<ReservationModel> _activeReservations = [];
  List<ReservationModel> _upcomingReservations = [];
  List<ReservationModel> _pastReservations = [];
  ReservationModel? _selectedReservation;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<ReservationModel> get reservations => _reservations;
  List<ReservationModel> get activeReservations => _activeReservations;
  List<ReservationModel> get upcomingReservations => _upcomingReservations;
  List<ReservationModel> get pastReservations => _pastReservations;
  ReservationModel? get selectedReservation => _selectedReservation;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load user reservations
  Future<void> loadUserReservations(String userId) async {
    try {
      _setLoading(true);
      
      _reservationService.getUserReservations(userId).listen((reservations) {
        _reservations = reservations;
        _categorizeReservations();
        notifyListeners();
      });
      
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Create a new reservation
  Future<bool> createReservation(ReservationModel reservation) async {
    try {
      _setLoading(true);
      _clearError();

      final reservationId = await _reservationService.createReservation(reservation);
      
      // Add the new reservation with the generated ID
      final newReservation = reservation.copyWith(id: reservationId);
      _reservations.insert(0, newReservation);
      _categorizeReservations();
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Get reservation by ID
  Future<void> getReservationById(String reservationId) async {
    try {
      _setLoading(true);
      
      final reservation = await _reservationService.getReservationById(reservationId);
      if (reservation != null) {
        _selectedReservation = reservation;
      }
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Update reservation
  Future<bool> updateReservation(ReservationModel reservation) async {
    try {
      _setLoading(true);
      _clearError();

      await _reservationService.updateReservation(reservation);
      
      // Update local list
      final index = _reservations.indexWhere((r) => r.id == reservation.id);
      if (index != -1) {
        _reservations[index] = reservation;
        _categorizeReservations();
      }
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Cancel reservation
  Future<bool> cancelReservation(String reservationId) async {
    try {
      _setLoading(true);
      _clearError();

      await _reservationService.cancelReservation(reservationId);
      
      // Update local list
      final index = _reservations.indexWhere((r) => r.id == reservationId);
      if (index != -1) {
        _reservations[index] = _reservations[index].copyWith(
          status: ReservationStatus.cancelled,
          updatedAt: DateTime.now(),
        );
        _categorizeReservations();
      }
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Extend reservation
  Future<bool> extendReservation({
    required String reservationId,
    required DateTime newEndTime,
    required double additionalAmount,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _reservationService.extendReservation(
        reservationId: reservationId,
        newEndTime: newEndTime,
        additionalAmount: additionalAmount,
      );
      
      // Update local list
      final index = _reservations.indexWhere((r) => r.id == reservationId);
      if (index != -1) {
        _reservations[index] = _reservations[index].copyWith(
          endTime: newEndTime,
          totalAmount: _reservations[index].totalAmount + additionalAmount,
          updatedAt: DateTime.now(),
        );
        _categorizeReservations();
      }
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Load active reservations
  Future<void> loadActiveReservations(String userId) async {
    try {
      _reservationService.getActiveReservations(userId).listen((reservations) {
        _activeReservations = reservations;
        notifyListeners();
      });
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Load upcoming reservations
  Future<void> loadUpcomingReservations(String userId) async {
    try {
      _upcomingReservations = await _reservationService.getUpcomingReservations(userId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Load past reservations
  Future<void> loadPastReservations(String userId) async {
    try {
      _pastReservations = await _reservationService.getPastReservations(userId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Categorize reservations
  void _categorizeReservations() {
    _activeReservations = _reservations.where((r) => r.isActive).toList();
    _upcomingReservations = _reservations.where((r) => r.isUpcoming).toList();
    _pastReservations = _reservations.where((r) => r.isPast).toList();
  }

  // Select reservation
  void selectReservation(ReservationModel reservation) {
    _selectedReservation = reservation;
    notifyListeners();
  }

  // Clear selected reservation
  void clearSelectedReservation() {
    _selectedReservation = null;
    notifyListeners();
  }

  // Get reservations by status
  List<ReservationModel> getReservationsByStatus(ReservationStatus status) {
    return _reservations.where((r) => r.status == status).toList();
  }

  // Get reservations by payment status
  List<ReservationModel> getReservationsByPaymentStatus(PaymentStatus status) {
    return _reservations.where((r) => r.paymentStatus == status).toList();
  }

  // Get reservations for a specific parking spot
  List<ReservationModel> getReservationsForSpot(String spotId) {
    return _reservations.where((r) => r.parkingSpotId == spotId).toList();
  }

  // Get reservations for a date range
  List<ReservationModel> getReservationsForDateRange(DateTime start, DateTime end) {
    return _reservations.where((r) => 
      r.startTime.isAfter(start) && r.endTime.isBefore(end)
    ).toList();
  }

  // Get total spent
  double get totalSpent {
    return _reservations
        .where((r) => r.paymentStatus == PaymentStatus.completed)
        .fold(0.0, (sum, r) => sum + r.totalAmount);
  }

  // Get average reservation duration
  Duration get averageReservationDuration {
    if (_reservations.isEmpty) return Duration.zero;
    
    int totalMinutes = _reservations
        .map((r) => r.duration.inMinutes)
        .reduce((a, b) => a + b);
    
    return Duration(minutes: totalMinutes ~/ _reservations.length);
  }

  // Get most used parking spot
  String? get mostUsedParkingSpot {
    if (_reservations.isEmpty) return null;
    
    Map<String, int> spotCounts = {};
    for (var reservation in _reservations) {
      spotCounts[reservation.parkingSpotId] = 
          (spotCounts[reservation.parkingSpotId] ?? 0) + 1;
    }
    
    return spotCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  // Get reservation statistics
  Map<String, dynamic> get statistics {
    int totalReservations = _reservations.length;
    int completedReservations = _reservations
        .where((r) => r.status == ReservationStatus.completed)
        .length;
    int cancelledReservations = _reservations
        .where((r) => r.status == ReservationStatus.cancelled)
        .length;
    
    double completionRate = totalReservations > 0 
        ? completedReservations / totalReservations 
        : 0.0;
    
    double cancellationRate = totalReservations > 0 
        ? cancelledReservations / totalReservations 
        : 0.0;

    return {
      'totalReservations': totalReservations,
      'completedReservations': completedReservations,
      'cancelledReservations': cancelledReservations,
      'activeReservations': _activeReservations.length,
      'upcomingReservations': _upcomingReservations.length,
      'completionRate': completionRate,
      'cancellationRate': cancellationRate,
      'totalSpent': totalSpent,
      'averageDuration': averageReservationDuration,
      'mostUsedSpot': mostUsedParkingSpot,
    };
  }

  // Check if user has active reservation
  bool get hasActiveReservation => _activeReservations.isNotEmpty;

  // Check if user has upcoming reservation
  bool get hasUpcomingReservation => _upcomingReservations.isNotEmpty;

  // Get next upcoming reservation
  ReservationModel? get nextUpcomingReservation {
    if (_upcomingReservations.isEmpty) return null;
    
    _upcomingReservations.sort((a, b) => a.startTime.compareTo(b.startTime));
    return _upcomingReservations.first;
  }

  // Get current active reservation
  ReservationModel? get currentActiveReservation {
    return _activeReservations.isNotEmpty ? _activeReservations.first : null;
  }

  // Refresh reservations
  Future<void> refresh(String userId) async {
    await loadUserReservations(userId);
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // Calculate reservation cost
  double calculateReservationCost({
    required double pricePerHour,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    final duration = endTime.difference(startTime);
    final hours = duration.inMinutes / 60.0;
    return pricePerHour * hours;
  }

  // Check if time slot is available for user
  bool isTimeSlotAvailable({
    required DateTime startTime,
    required DateTime endTime,
    String? excludeReservationId,
  }) {
    for (var reservation in _reservations) {
      // Skip cancelled or completed reservations
      if (reservation.status == ReservationStatus.cancelled ||
          reservation.status == ReservationStatus.completed) {
        continue;
      }
      
      // Skip the reservation being updated
      if (excludeReservationId != null && 
          reservation.id == excludeReservationId) {
        continue;
      }
      
      // Check for overlap
      if (startTime.isBefore(reservation.endTime) && 
          endTime.isAfter(reservation.startTime)) {
        return false;
      }
    }
    
    return true;
  }
}
