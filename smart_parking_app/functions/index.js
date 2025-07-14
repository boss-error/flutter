const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');

admin.initializeApp();

// Gemini AI API configuration
const GEMINI_API_KEY = functions.config().gemini?.api_key || 'your-gemini-api-key-here';
const GEMINI_API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent';

/**
 * Firebase Cloud Function for Gemini AI Integration
 * Handles various AI-powered parking predictions and recommendations
 */
exports.geminiAiPrediction = functions.https.onCall(async (data, context) => {
  try {
    // Verify user authentication
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { type, data: requestData } = data;

    switch (type) {
      case 'parking_prediction':
        return await getParkingPrediction(requestData);
      case 'smart_recommendations':
        return await getSmartRecommendations(requestData);
      case 'traffic_insights':
        return await getTrafficInsights(requestData);
      case 'optimal_times':
        return await getOptimalParkingTimes(requestData);
      case 'personalized_suggestions':
        return await getPersonalizedSuggestions(requestData);
      case 'pattern_analysis':
        return await analyzeParkingPatterns(requestData);
      case 'search_suggestions':
        return await getSearchSuggestions(requestData);
      case 'demand_forecast':
        return await getParkingDemandForecast(requestData);
      case 'chat_response':
        return await getChatResponse(requestData);
      default:
        throw new functions.https.HttpsError('invalid-argument', 'Invalid prediction type');
    }
  } catch (error) {
    console.error('Error in geminiAiPrediction:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

/**
 * Get parking availability predictions using Gemini AI
 */
async function getParkingPrediction(data) {
  const { latitude, longitude, targetTime, zone } = data;
  
  // Get historical parking data
  const historicalData = await getHistoricalParkingData(latitude, longitude, zone);
  
  const prompt = `
    Based on the following historical parking data and current conditions, predict parking availability:
    
    Location: Latitude ${latitude}, Longitude ${longitude}
    Target Time: ${targetTime}
    Zone: ${zone || 'Not specified'}
    
    Historical Data: ${JSON.stringify(historicalData)}
    
    Please provide:
    1. Availability prediction (percentage)
    2. Best alternative times
    3. Recommended parking spots nearby
    4. Confidence level of prediction
    
    Respond in JSON format with keys: availability, alternatives, recommendations, confidence
  `;

  const aiResponse = await callGeminiAPI(prompt);
  
  return {
    prediction: aiResponse,
    timestamp: new Date().toISOString(),
    location: { latitude, longitude },
    targetTime
  };
}

/**
 * Get smart parking recommendations
 */
async function getSmartRecommendations(data) {
  const { userId, latitude, longitude, preferredTime, maxPrice, preferredFeatures } = data;
  
  // Get user preferences and history
  const userHistory = await getUserParkingHistory(userId);
  const nearbySpots = await getNearbyParkingSpots(latitude, longitude);
  
  const prompt = `
    Provide smart parking recommendations based on:
    
    User Location: ${latitude}, ${longitude}
    Preferred Time: ${preferredTime || 'Not specified'}
    Max Price: $${maxPrice || 'No limit'}
    Preferred Features: ${preferredFeatures?.join(', ') || 'None specified'}
    
    User History: ${JSON.stringify(userHistory)}
    Available Spots: ${JSON.stringify(nearbySpots)}
    
    Rank the top 5 recommendations considering:
    - Distance from user
    - Price optimization
    - Feature preferences
    - Historical user behavior
    - Current availability
    
    Respond in JSON format with array of recommendations, each containing:
    spotId, name, distance, price, features, score, reasoning
  `;

  const aiResponse = await callGeminiAPI(prompt);
  
  return {
    recommendations: aiResponse,
    timestamp: new Date().toISOString(),
    userLocation: { latitude, longitude }
  };
}

/**
 * Get traffic and parking insights
 */
async function getTrafficInsights(data) {
  const { latitude, longitude, targetTime } = data;
  
  const prompt = `
    Analyze traffic and parking conditions for:
    Location: ${latitude}, ${longitude}
    Time: ${targetTime}
    
    Consider:
    - Current traffic patterns
    - Peak hours impact
    - Event-based congestion
    - Weather conditions
    - Day of week patterns
    
    Provide insights on:
    1. Traffic congestion level (1-10)
    2. Parking difficulty (1-10)
    3. Best routes to parking
    4. Alternative timing suggestions
    5. Expected search time
    
    Respond in JSON format.
  `;

  const aiResponse = await callGeminiAPI(prompt);
  
  return {
    insights: aiResponse,
    timestamp: new Date().toISOString(),
    location: { latitude, longitude }
  };
}

/**
 * Get optimal parking times
 */
async function getOptimalParkingTimes(data) {
  const { parkingSpotId, startDate, endDate } = data;
  
  const spotData = await getParkingSpotData(parkingSpotId);
  const occupancyHistory = await getOccupancyHistory(parkingSpotId, startDate, endDate);
  
  const prompt = `
    Analyze optimal parking times for spot ${parkingSpotId}:
    
    Spot Details: ${JSON.stringify(spotData)}
    Occupancy History: ${JSON.stringify(occupancyHistory)}
    Date Range: ${startDate} to ${endDate}
    
    Find the best times to park considering:
    - Lowest occupancy rates
    - Price variations
    - Duration availability
    - User convenience
    
    Provide top 10 optimal time slots with:
    startTime, endTime, occupancyRate, price, score, reasoning
    
    Respond in JSON format.
  `;

  const aiResponse = await callGeminiAPI(prompt);
  
  return {
    optimalTimes: aiResponse,
    spotId: parkingSpotId,
    dateRange: { startDate, endDate }
  };
}

/**
 * Get personalized suggestions based on user history
 */
async function getPersonalizedSuggestions(data) {
  const { userId, latitude, longitude } = data;
  
  const userProfile = await getUserProfile(userId);
  const parkingHistory = await getUserParkingHistory(userId);
  const preferences = await getUserPreferences(userId);
  
  const prompt = `
    Create personalized parking suggestions for user ${userId}:
    
    Current Location: ${latitude}, ${longitude}
    User Profile: ${JSON.stringify(userProfile)}
    Parking History: ${JSON.stringify(parkingHistory)}
    Preferences: ${JSON.stringify(preferences)}
    
    Analyze patterns and provide:
    1. Favorite parking types
    2. Price sensitivity
    3. Distance preferences
    4. Time patterns
    5. Feature preferences
    
    Generate personalized recommendations with explanations.
    
    Respond in JSON format.
  `;

  const aiResponse = await callGeminiAPI(prompt);
  
  return {
    suggestions: aiResponse,
    userId,
    timestamp: new Date().toISOString()
  };
}

/**
 * Analyze parking patterns
 */
async function analyzeParkingPatterns(data) {
  const { userId, days } = data;
  
  const recentHistory = await getUserRecentHistory(userId, days);
  
  const prompt = `
    Analyze parking patterns for user over ${days} days:
    
    Parking History: ${JSON.stringify(recentHistory)}
    
    Identify:
    1. Most frequent parking times
    2. Preferred locations/zones
    3. Average parking duration
    4. Spending patterns
    5. Seasonal variations
    6. Behavioral insights
    
    Provide actionable insights and recommendations.
    
    Respond in JSON format.
  `;

  const aiResponse = await callGeminiAPI(prompt);
  
  return {
    patterns: aiResponse,
    analysisPeriod: days,
    timestamp: new Date().toISOString()
  };
}

/**
 * Get AI-powered search suggestions
 */
async function getSearchSuggestions(data) {
  const { query, latitude, longitude } = data;
  
  const nearbySpots = await getNearbyParkingSpots(latitude, longitude);
  const popularSearches = await getPopularSearches();
  
  const prompt = `
    Generate search suggestions for query: "${query}"
    
    User Location: ${latitude}, ${longitude}
    Nearby Spots: ${JSON.stringify(nearbySpots)}
    Popular Searches: ${JSON.stringify(popularSearches)}
    
    Provide relevant, contextual search suggestions that help users find parking.
    Consider location names, parking types, features, and common search patterns.
    
    Return array of 5-10 search suggestions.
    
    Respond in JSON format with array of strings.
  `;

  const aiResponse = await callGeminiAPI(prompt);
  
  return {
    suggestions: aiResponse,
    query,
    location: { latitude, longitude }
  };
}

/**
 * Get parking demand forecast
 */
async function getParkingDemandForecast(data) {
  const { zone, startTime, endTime } = data;
  
  const historicalDemand = await getHistoricalDemand(zone, startTime, endTime);
  const events = await getUpcomingEvents(zone, startTime, endTime);
  
  const prompt = `
    Forecast parking demand for zone ${zone}:
    
    Time Period: ${startTime} to ${endTime}
    Historical Demand: ${JSON.stringify(historicalDemand)}
    Upcoming Events: ${JSON.stringify(events)}
    
    Consider:
    - Historical patterns
    - Seasonal variations
    - Special events impact
    - Weather forecasts
    - Day of week patterns
    
    Provide hourly demand forecast with confidence levels.
    
    Respond in JSON format.
  `;

  const aiResponse = await callGeminiAPI(prompt);
  
  return {
    forecast: aiResponse,
    zone,
    period: { startTime, endTime }
  };
}

/**
 * Get AI chat response for parking queries
 */
async function getChatResponse(data) {
  const { message, context, userLocation } = data;
  
  const prompt = `
    You are a smart parking assistant. Respond to this user query:
    
    User Message: "${message}"
    Context: ${context || 'None'}
    User Location: ${userLocation ? JSON.stringify(userLocation) : 'Unknown'}
    
    Provide helpful, accurate information about parking. Be conversational and helpful.
    If you need more information, ask clarifying questions.
    
    Respond as plain text, not JSON.
  `;

  const aiResponse = await callGeminiAPI(prompt);
  
  return {
    response: aiResponse,
    timestamp: new Date().toISOString()
  };
}

/**
 * Call Gemini AI API
 */
async function callGeminiAPI(prompt) {
  try {
    const response = await axios.post(
      GEMINI_API_URL,
      {
        contents: [
          {
            parts: [
              {
                text: prompt
              }
            ]
          }
        ]
      },
      {
        headers: {
          'x-goog-api-key': GEMINI_API_KEY,
          'Content-Type': 'application/json'
        }
      }
    );

    const aiResponse = response.data.candidates[0].content.parts[0].text;
    
    // Try to parse as JSON, fallback to text
    try {
      return JSON.parse(aiResponse);
    } catch {
      return aiResponse;
    }
  } catch (error) {
    console.error('Error calling Gemini API:', error);
    throw new Error('Failed to get AI response');
  }
}

// Helper functions to get data from Firestore
async function getHistoricalParkingData(latitude, longitude, zone) {
  // Implementation to fetch historical data
  return {};
}

async function getUserParkingHistory(userId) {
  // Implementation to fetch user history
  return {};
}

async function getNearbyParkingSpots(latitude, longitude) {
  // Implementation to fetch nearby spots
  return [];
}

async function getParkingSpotData(spotId) {
  // Implementation to fetch spot data
  return {};
}

async function getOccupancyHistory(spotId, startDate, endDate) {
  // Implementation to fetch occupancy history
  return {};
}

async function getUserProfile(userId) {
  // Implementation to fetch user profile
  return {};
}

async function getUserPreferences(userId) {
  // Implementation to fetch user preferences
  return {};
}

async function getUserRecentHistory(userId, days) {
  // Implementation to fetch recent history
  return {};
}

async function getPopularSearches() {
  // Implementation to fetch popular searches
  return [];
}

async function getHistoricalDemand(zone, startTime, endTime) {
  // Implementation to fetch historical demand
  return {};
}

async function getUpcomingEvents(zone, startTime, endTime) {
  // Implementation to fetch upcoming events
  return [];
}
