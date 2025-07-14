import 'package:cloud_functions/cloud_functions.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AIService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Get AI predictions for parking availability
  Future<Map<String, dynamic>> getParkingPredictions({
    required double latitude,
    required double longitude,
    required DateTime targetTime,
    String? zone,
  }) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('geminiAiPrediction');
      
      final result = await callable.call({
        'type': 'parking_prediction',
        'data': {
          'latitude': latitude,
          'longitude': longitude,
          'targetTime': targetTime.toIso8601String(),
          'zone': zone,
        }
      });

      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      throw Exception('Failed to get AI predictions: $e');
    }
  }

  // Get smart parking recommendations
  Future<List<Map<String, dynamic>>> getSmartRecommendations({
    required String userId,
    required double latitude,
    required double longitude,
    DateTime? preferredTime,
    double? maxPrice,
    List<String>? preferredFeatures,
  }) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('geminiAiPrediction');
      
      final result = await callable.call({
        'type': 'smart_recommendations',
        'data': {
          'userId': userId,
          'latitude': latitude,
          'longitude': longitude,
          'preferredTime': preferredTime?.toIso8601String(),
          'maxPrice': maxPrice,
          'preferredFeatures': preferredFeatures,
        }
      });

      return List<Map<String, dynamic>>.from(result.data['recommendations']);
    } catch (e) {
      throw Exception('Failed to get smart recommendations: $e');
    }
  }

  // Get traffic and parking insights
  Future<Map<String, dynamic>> getTrafficInsights({
    required double latitude,
    required double longitude,
    required DateTime targetTime,
  }) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('geminiAiPrediction');
      
      final result = await callable.call({
        'type': 'traffic_insights',
        'data': {
          'latitude': latitude,
          'longitude': longitude,
          'targetTime': targetTime.toIso8601String(),
        }
      });

      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      throw Exception('Failed to get traffic insights: $e');
    }
  }

  // Get optimal parking time suggestions
  Future<List<Map<String, dynamic>>> getOptimalParkingTimes({
    required String parkingSpotId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('geminiAiPrediction');
      
      final result = await callable.call({
        'type': 'optimal_times',
        'data': {
          'parkingSpotId': parkingSpotId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        }
      });

      return List<Map<String, dynamic>>.from(result.data['optimalTimes']);
    } catch (e) {
      throw Exception('Failed to get optimal parking times: $e');
    }
  }

  // Get personalized parking suggestions based on user history
  Future<Map<String, dynamic>> getPersonalizedSuggestions({
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('geminiAiPrediction');
      
      final result = await callable.call({
        'type': 'personalized_suggestions',
        'data': {
          'userId': userId,
          'latitude': latitude,
          'longitude': longitude,
        }
      });

      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      throw Exception('Failed to get personalized suggestions: $e');
    }
  }

  // Analyze parking patterns
  Future<Map<String, dynamic>> analyzeParkingPatterns({
    required String userId,
    int? days = 30,
  }) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('geminiAiPrediction');
      
      final result = await callable.call({
        'type': 'pattern_analysis',
        'data': {
          'userId': userId,
          'days': days,
        }
      });

      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      throw Exception('Failed to analyze parking patterns: $e');
    }
  }

  // Get AI-powered search suggestions
  Future<List<String>> getSearchSuggestions({
    required String query,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('geminiAiPrediction');
      
      final result = await callable.call({
        'type': 'search_suggestions',
        'data': {
          'query': query,
          'latitude': latitude,
          'longitude': longitude,
        }
      });

      return List<String>.from(result.data['suggestions']);
    } catch (e) {
      throw Exception('Failed to get search suggestions: $e');
    }
  }

  // Get parking demand forecast
  Future<Map<String, dynamic>> getParkingDemandForecast({
    required String zone,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('geminiAiPrediction');
      
      final result = await callable.call({
        'type': 'demand_forecast',
        'data': {
          'zone': zone,
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
        }
      });

      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      throw Exception('Failed to get demand forecast: $e');
    }
  }

  // Get AI chat response for parking queries
  Future<String> getChatResponse({
    required String message,
    String? context,
    Map<String, dynamic>? userLocation,
  }) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('geminiAiPrediction');
      
      final result = await callable.call({
        'type': 'chat_response',
        'data': {
          'message': message,
          'context': context,
          'userLocation': userLocation,
        }
      });

      return result.data['response'] as String;
    } catch (e) {
      throw Exception('Failed to get chat response: $e');
    }
  }
}

// AI Prediction Types
enum AIPredictionType {
  parkingAvailability,
  trafficConditions,
  optimalRoute,
  priceOptimization,
  demandForecast,
}

// AI Insight Model
class AIInsight {
  final String id;
  final AIPredictionType type;
  final String title;
  final String description;
  final Map<String, dynamic> data;
  final double confidence;
  final DateTime createdAt;
  final DateTime validUntil;

  AIInsight({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.data,
    required this.confidence,
    required this.createdAt,
    required this.validUntil,
  });

  factory AIInsight.fromMap(Map<String, dynamic> map) {
    return AIInsight(
      id: map['id'] ?? '',
      type: AIPredictionType.values.firstWhere(
        (e) => e.toString() == 'AIPredictionType.${map['type']}',
        orElse: () => AIPredictionType.parkingAvailability,
      ),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
      validUntil: DateTime.parse(map['validUntil']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'title': title,
      'description': description,
      'data': data,
      'confidence': confidence,
      'createdAt': createdAt.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
    };
  }

  bool get isValid => DateTime.now().isBefore(validUntil);
  bool get isHighConfidence => confidence >= 0.8;
}
