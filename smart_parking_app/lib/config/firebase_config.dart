import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  static const String projectId = 'smart-parking-system';
  static const String apiKey = 'your-api-key-here';
  static const String appId = 'your-app-id-here';
  static const String messagingSenderId = 'your-sender-id-here';
  static const String storageBucket = 'smart-parking-system.appspot.com';

  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      storageBucket: storageBucket,
    );
  }

  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: currentPlatform,
    );
  }
}

// Firestore Collections
class FirestoreCollections {
  static const String users = 'users';
  static const String parkingSpots = 'parking_spots';
  static const String reservations = 'reservations';
  static const String payments = 'payments';
  static const String reviews = 'reviews';
  static const String notifications = 'notifications';
}

// Cloud Functions
class CloudFunctions {
  static const String geminiAiPrediction = 'geminiAiPrediction';
  static const String processPayment = 'processPayment';
  static const String sendNotification = 'sendNotification';
  static const String updateParkingAvailability = 'updateParkingAvailability';
}
