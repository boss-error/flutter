import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/parking_spot_model.dart';
import '../services/parking_service.dart';

class ParkingProvider with ChangeNotifier {
  final ParkingService _parkingService = ParkingService();
  
  List<ParkingSpotModel> _parkingSpots = [];
  List<ParkingSpotModel> _nearbySpots = [];
  List<ParkingSpotModel> _filteredSpots = [];
  ParkingSpotModel? _selectedSpot;
  Position? _currentPosition;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Filter options
  ParkingSpotType? _selectedType;
  double? _maxPrice;
  List<String> _selectedFeatures = [];
  double _searchRadius = 5.0; // km

  // Getters
  List<ParkingSpotModel> get parkingSpots => _parkingSpots;
  List<ParkingSpotModel> get nearbySpots => _nearbySpots;
  List<ParkingSpotModel> get filteredSpots => _filteredSpots;
  ParkingSpotModel? get selectedSpot => _selectedSpot;
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ParkingSpotType? get selectedType => _selectedType;
  double? get maxPrice => _maxPrice;
  List<String> get selectedFeatures => _selectedFeatures;
  double get searchRadius => _searchRadius;

  // Initialize parking data
  Future<void> initialize() async {
    await getCurrentLocation();
    await loadParkingSpots();
  }

  // Get current location
  Future<void> getCurrentLocation() async {
    try {
      _setLoading(true);
      
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await loadNearbySpots();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Load all parking spots
  Future<void> loadParkingSpots() async {
    try {
      _setLoading(true);
      
      _parkingService.getAllParkingSpots().listen((spots) {
        _parkingSpots = spots;
        _applyFilters();
        notifyListeners();
      });
      
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Load nearby parking spots
  Future<void> loadNearbySpots() async {
    if (_currentPosition == null) return;

    try {
      _setLoading(true);
      
      _nearbySpots = await _parkingService.getParkingSpotsNearby(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        radiusInKm: _searchRadius,
      );
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Search parking spots
  Future<void> searchParkingSpots(String query) async {
    try {
      _setLoading(true);
      
      final results = await _parkingService.searchParkingSpots(
        query: query,
        type: _selectedType,
        maxPrice: _maxPrice,
        features: _selectedFeatures,
      );
      
      _filteredSpots = results;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Get parking spot by ID
  Future<void> getParkingSpotById(String spotId) async {
    try {
      _setLoading(true);
      
      final spot = await _parkingService.getParkingSpotById(spotId);
      if (spot != null) {
        _selectedSpot = spot;
      }
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Select a parking spot
  void selectSpot(ParkingSpotModel spot) {
    _selectedSpot = spot;
    notifyListeners();
  }

  // Clear selected spot
  void clearSelectedSpot() {
    _selectedSpot = null;
    notifyListeners();
  }

  // Set filter type
  void setFilterType(ParkingSpotType? type) {
    _selectedType = type;
    _applyFilters();
    notifyListeners();
  }

  // Set max price filter
  void setMaxPrice(double? price) {
    _maxPrice = price;
    _applyFilters();
    notifyListeners();
  }

  // Toggle feature filter
  void toggleFeature(String feature) {
    if (_selectedFeatures.contains(feature)) {
      _selectedFeatures.remove(feature);
    } else {
      _selectedFeatures.add(feature);
    }
    _applyFilters();
    notifyListeners();
  }

  // Set search radius
  void setSearchRadius(double radius) {
    _searchRadius = radius;
    if (_currentPosition != null) {
      loadNearbySpots();
    }
  }

  // Apply filters to parking spots
  void _applyFilters() {
    _filteredSpots = _parkingSpots.where((spot) {
      // Type filter
      if (_selectedType != null && spot.type != _selectedType) {
        return false;
      }

      // Price filter
      if (_maxPrice != null && spot.pricePerHour > _maxPrice!) {
        return false;
      }

      // Features filter
      if (_selectedFeatures.isNotEmpty) {
        for (String feature in _selectedFeatures) {
          if (!spot.features.contains(feature)) {
            return false;
          }
        }
      }

      return true;
    }).toList();
  }

  // Clear all filters
  void clearFilters() {
    _selectedType = null;
    _maxPrice = null;
    _selectedFeatures.clear();
    _applyFilters();
    notifyListeners();
  }

  // Get available parking spots
  List<ParkingSpotModel> get availableSpots {
    return _filteredSpots.where((spot) => spot.isAvailable).toList();
  }

  // Get spots by type
  List<ParkingSpotModel> getSpotsByType(ParkingSpotType type) {
    return _filteredSpots.where((spot) => spot.type == type).toList();
  }

  // Get spots in price range
  List<ParkingSpotModel> getSpotsInPriceRange(double minPrice, double maxPrice) {
    return _filteredSpots.where((spot) => 
      spot.pricePerHour >= minPrice && spot.pricePerHour <= maxPrice
    ).toList();
  }

  // Sort spots by distance (requires current position)
  List<ParkingSpotModel> getSortedByDistance() {
    if (_currentPosition == null) return _filteredSpots;

    List<ParkingSpotModel> sortedSpots = List.from(_filteredSpots);
    sortedSpots.sort((a, b) {
      double distanceA = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        a.location.latitude,
        a.location.longitude,
      );
      double distanceB = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        b.location.latitude,
        b.location.longitude,
      );
      return distanceA.compareTo(distanceB);
    });

    return sortedSpots;
  }

  // Sort spots by price
  List<ParkingSpotModel> getSortedByPrice({bool ascending = true}) {
    List<ParkingSpotModel> sortedSpots = List.from(_filteredSpots);
    sortedSpots.sort((a, b) {
      return ascending 
        ? a.pricePerHour.compareTo(b.pricePerHour)
        : b.pricePerHour.compareTo(a.pricePerHour);
    });
    return sortedSpots;
  }

  // Sort spots by availability
  List<ParkingSpotModel> getSortedByAvailability() {
    List<ParkingSpotModel> sortedSpots = List.from(_filteredSpots);
    sortedSpots.sort((a, b) {
      return b.availableSpots.compareTo(a.availableSpots);
    });
    return sortedSpots;
  }

  // Get distance to spot
  double? getDistanceToSpot(ParkingSpotModel spot) {
    if (_currentPosition == null) return null;

    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      spot.location.latitude,
      spot.location.longitude,
    ) / 1000; // Convert to kilometers
  }

  // Refresh parking data
  Future<void> refresh() async {
    await loadParkingSpots();
    if (_currentPosition != null) {
      await loadNearbySpots();
    }
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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get parking statistics
  Map<String, dynamic> get statistics {
    int totalSpots = _parkingSpots.length;
    int availableSpots = _parkingSpots.where((spot) => spot.isAvailable).length;
    int occupiedSpots = totalSpots - availableSpots;
    
    double averagePrice = 0.0;
    if (_parkingSpots.isNotEmpty) {
      averagePrice = _parkingSpots
        .map((spot) => spot.pricePerHour)
        .reduce((a, b) => a + b) / _parkingSpots.length;
    }

    return {
      'totalSpots': totalSpots,
      'availableSpots': availableSpots,
      'occupiedSpots': occupiedSpots,
      'occupancyRate': totalSpots > 0 ? occupiedSpots / totalSpots : 0.0,
      'averagePrice': averagePrice,
    };
  }

  // Get common features
  List<String> get commonFeatures {
    Set<String> features = {};
    for (var spot in _parkingSpots) {
      features.addAll(spot.features);
    }
    return features.toList()..sort();
  }

  // Get price range
  Map<String, double> get priceRange {
    if (_parkingSpots.isEmpty) {
      return {'min': 0.0, 'max': 0.0};
    }

    double minPrice = _parkingSpots.first.pricePerHour;
    double maxPrice = _parkingSpots.first.pricePerHour;

    for (var spot in _parkingSpots) {
      if (spot.pricePerHour < minPrice) minPrice = spot.pricePerHour;
      if (spot.pricePerHour > maxPrice) maxPrice = spot.pricePerHour;
    }

    return {'min': minPrice, 'max': maxPrice};
  }
}
