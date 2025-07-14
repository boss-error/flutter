import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class AIProvider with ChangeNotifier {
  final AIService _aiService = AIService();
  
  Map<String, dynamic>? _parkingPredictions;
  List<Map<String, dynamic>> _smartRecommendations = [];
  Map<String, dynamic>? _trafficInsights;
  List<Map<String, dynamic>> _optimalTimes = [];
  Map<String, dynamic>? _personalizedSuggestions;
  Map<String, dynamic>? _parkingPatterns;
  List<String> _searchSuggestions = [];
  Map<String, dynamic>? _demandForecast;
  String? _chatResponse;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Map<String, dynamic>? get parkingPredictions => _parkingPredictions;
  List<Map<String, dynamic>> get smartRecommendations => _smartRecommendations;
  Map<String, dynamic>? get trafficInsights => _trafficInsights;
  List<Map<String, dynamic>> get optimalTimes => _optimalTimes;
  Map<String, dynamic>? get personalizedSuggestions => _personalizedSuggestions;
  Map<String, dynamic>? get parkingPatterns => _parkingPatterns;
  List<String> get searchSuggestions => _searchSuggestions;
  Map<String, dynamic>? get demandForecast => _demandForecast;
  String? get chatResponse => _chatResponse;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get parking predictions
  Future<void> getParkingPredictions({
    required double latitude,
    required double longitude,
    required DateTime targetTime,
    String? zone,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      _parkingPredictions = await _aiService.getParkingPredictions(
        latitude: latitude,
        longitude: longitude,
        targetTime: targetTime,
        zone: zone,
      );

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Get smart recommendations
  Future<void> getSmartRecommendations({
    required String userId,
    required double latitude,
    required double longitude,
    DateTime? preferredTime,
    double? maxPrice,
    List<String>? preferredFeatures,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      _smartRecommendations = await _aiService.getSmartRecommendations(
        userId: userId,
        latitude: latitude,
        longitude: longitude,
        preferredTime: preferredTime,
        maxPrice: maxPrice,
        preferredFeatures: preferredFeatures,
      );

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Get traffic insights
  Future<void> getTrafficInsights({
    required double latitude,
    required double longitude,
    required DateTime targetTime,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      _trafficInsights = await _aiService.getTrafficInsights(
        latitude: latitude,
        longitude: longitude,
        targetTime: targetTime,
      );

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Get optimal parking times
  Future<void> getOptimalParkingTimes({
    required String parkingSpotId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      _optimalTimes = await _aiService.getOptimalParkingTimes(
        parkingSpotId: parkingSpotId,
        startDate: startDate,
        endDate: endDate,
      );

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Get personalized suggestions
  Future<void> getPersonalizedSuggestions({
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      _personalizedSuggestions = await _aiService.getPersonalizedSuggestions(
        userId: userId,
        latitude: latitude,
        longitude: longitude,
      );

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Analyze parking patterns
  Future<void> analyzeParkingPatterns({
    required String userId,
    int? days = 30,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      _parkingPatterns = await _aiService.analyzeParkingPatterns(
        userId: userId,
        days: days,
      );

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Get search suggestions
  Future<void> getSearchSuggestions({
    required String query,
    required double latitude,
    required double longitude,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      _searchSuggestions = await _aiService.getSearchSuggestions(
        query: query,
        latitude: latitude,
        longitude: longitude,
      );

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Get parking demand forecast
  Future<void> getParkingDemandForecast({
    required String zone,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      _demandForecast = await _aiService.getParkingDemandForecast(
        zone: zone,
        startTime: startTime,
        endTime: endTime,
      );

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Get AI chat response
  Future<void> getChatResponse({
    required String message,
    String? context,
    Map<String, dynamic>? userLocation,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      _chatResponse = await _aiService.getChatResponse(
        message: message,
        context: context,
        userLocation: userLocation,
      );

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Clear chat response
  void clearChatResponse() {
    _chatResponse = null;
    notifyListeners();
  }

  // Get availability prediction percentage
  double? get availabilityPrediction {
    if (_parkingPredictions == null) return null;
    
    final prediction = _parkingPredictions!['prediction'];
    if (prediction is Map<String, dynamic> && prediction.containsKey('availability')) {
      return (prediction['availability'] as num?)?.toDouble();
    }
    return null;
  }

  // Get prediction confidence
  double? get predictionConfidence {
    if (_parkingPredictions == null) return null;
    
    final prediction = _parkingPredictions!['prediction'];
    if (prediction is Map<String, dynamic> && prediction.containsKey('confidence')) {
      return (prediction['confidence'] as num?)?.toDouble();
    }
    return null;
  }

  // Get alternative times
  List<String> get alternativeTimes {
    if (_parkingPredictions == null) return [];
    
    final prediction = _parkingPredictions!['prediction'];
    if (prediction is Map<String, dynamic> && prediction.containsKey('alternatives')) {
      final alternatives = prediction['alternatives'];
      if (alternatives is List) {
        return alternatives.map((e) => e.toString()).toList();
      }
    }
    return [];
  }

  // Get recommended spots from predictions
  List<String> get recommendedSpots {
    if (_parkingPredictions == null) return [];
    
    final prediction = _parkingPredictions!['prediction'];
    if (prediction is Map<String, dynamic> && prediction.containsKey('recommendations')) {
      final recommendations = prediction['recommendations'];
      if (recommendations is List) {
        return recommendations.map((e) => e.toString()).toList();
      }
    }
    return [];
  }

  // Get traffic congestion level
  int? get trafficCongestionLevel {
    if (_trafficInsights == null) return null;
    
    final insights = _trafficInsights!['insights'];
    if (insights is Map<String, dynamic> && insights.containsKey('trafficCongestion')) {
      return (insights['trafficCongestion'] as num?)?.toInt();
    }
    return null;
  }

  // Get parking difficulty level
  int? get parkingDifficultyLevel {
    if (_trafficInsights == null) return null;
    
    final insights = _trafficInsights!['insights'];
    if (insights is Map<String, dynamic> && insights.containsKey('parkingDifficulty')) {
      return (insights['parkingDifficulty'] as num?)?.toInt();
    }
    return null;
  }

  // Get expected search time
  int? get expectedSearchTime {
    if (_trafficInsights == null) return null;
    
    final insights = _trafficInsights!['insights'];
    if (insights is Map<String, dynamic> && insights.containsKey('expectedSearchTime')) {
      return (insights['expectedSearchTime'] as num?)?.toInt();
    }
    return null;
  }

  // Get top recommendation
  Map<String, dynamic>? get topRecommendation {
    if (_smartRecommendations.isEmpty) return null;
    return _smartRecommendations.first;
  }

  // Get recommendations by score
  List<Map<String, dynamic>> getRecommendationsByScore({bool descending = true}) {
    List<Map<String, dynamic>> sorted = List.from(_smartRecommendations);
    sorted.sort((a, b) {
      double scoreA = (a['score'] as num?)?.toDouble() ?? 0.0;
      double scoreB = (b['score'] as num?)?.toDouble() ?? 0.0;
      return descending ? scoreB.compareTo(scoreA) : scoreA.compareTo(scoreB);
    });
    return sorted;
  }

  // Get recommendations by distance
  List<Map<String, dynamic>> getRecommendationsByDistance({bool ascending = true}) {
    List<Map<String, dynamic>> sorted = List.from(_smartRecommendations);
    sorted.sort((a, b) {
      double distanceA = (a['distance'] as num?)?.toDouble() ?? double.infinity;
      double distanceB = (b['distance'] as num?)?.toDouble() ?? double.infinity;
      return ascending ? distanceA.compareTo(distanceB) : distanceB.compareTo(distanceA);
    });
    return sorted;
  }

  // Get recommendations by price
  List<Map<String, dynamic>> getRecommendationsByPrice({bool ascending = true}) {
    List<Map<String, dynamic>> sorted = List.from(_smartRecommendations);
    sorted.sort((a, b) {
      double priceA = (a['price'] as num?)?.toDouble() ?? double.infinity;
      double priceB = (b['price'] as num?)?.toDouble() ?? double.infinity;
      return ascending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
    });
    return sorted;
  }

  // Check if AI data is fresh (less than 5 minutes old)
  bool get isPredictionFresh {
    if (_parkingPredictions == null) return false;
    
    final timestamp = _parkingPredictions!['timestamp'];
    if (timestamp is String) {
      final predictionTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      return now.difference(predictionTime).inMinutes < 5;
    }
    return false;
  }

  // Get parking pattern insights
  Map<String, dynamic> get patternInsights {
    if (_parkingPatterns == null) return {};
    return _parkingPatterns!['patterns'] ?? {};
  }

  // Get most frequent parking times
  List<String> get frequentParkingTimes {
    final insights = patternInsights;
    if (insights.containsKey('frequentTimes')) {
      final times = insights['frequentTimes'];
      if (times is List) {
        return times.map((e) => e.toString()).toList();
      }
    }
    return [];
  }

  // Get preferred locations
  List<String> get preferredLocations {
    final insights = patternInsights;
    if (insights.containsKey('preferredLocations')) {
      final locations = insights['preferredLocations'];
      if (locations is List) {
        return locations.map((e) => e.toString()).toList();
      }
    }
    return [];
  }

  // Get average parking duration from patterns
  String? get averageParkingDuration {
    final insights = patternInsights;
    if (insights.containsKey('averageDuration')) {
      return insights['averageDuration'].toString();
    }
    return null;
  }

  // Get spending patterns
  Map<String, dynamic> get spendingPatterns {
    final insights = patternInsights;
    if (insights.containsKey('spendingPatterns')) {
      return insights['spendingPatterns'] ?? {};
    }
    return {};
  }

  // Clear all AI data
  void clearAllData() {
    _parkingPredictions = null;
    _smartRecommendations.clear();
    _trafficInsights = null;
    _optimalTimes.clear();
    _personalizedSuggestions = null;
    _parkingPatterns = null;
    _searchSuggestions.clear();
    _demandForecast = null;
    _chatResponse = null;
    notifyListeners();
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

  // Check if any AI data is available
  bool get hasAnyData {
    return _parkingPredictions != null ||
           _smartRecommendations.isNotEmpty ||
           _trafficInsights != null ||
           _optimalTimes.isNotEmpty ||
           _personalizedSuggestions != null ||
           _parkingPatterns != null ||
           _searchSuggestions.isNotEmpty ||
           _demandForecast != null;
  }

  // Get AI insights summary
  Map<String, dynamic> get insightsSummary {
    return {
      'hasPredictions': _parkingPredictions != null,
      'hasRecommendations': _smartRecommendations.isNotEmpty,
      'hasTrafficInsights': _trafficInsights != null,
      'hasOptimalTimes': _optimalTimes.isNotEmpty,
      'hasPersonalizedSuggestions': _personalizedSuggestions != null,
      'hasPatterns': _parkingPatterns != null,
      'hasSearchSuggestions': _searchSuggestions.isNotEmpty,
      'hasDemandForecast': _demandForecast != null,
      'isPredictionFresh': isPredictionFresh,
      'recommendationsCount': _smartRecommendations.length,
      'optimalTimesCount': _optimalTimes.length,
      'searchSuggestionsCount': _searchSuggestions.length,
    };
  }
}
