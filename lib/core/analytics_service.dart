import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:firebase_analytics/firebase_analytics.dart';

// import 'package:amplitude_flutter/amplitude_flutter.dart';

// const String _amplitudeApiKey = 'your_amplitude_api_key_here';

class AnalyticsService {

  late final FirebaseAnalytics _firebaseAnalytics;

  // late final Amplitude _amplitude;

  Future<void> init() async {
    if (kIsWeb) {
      try {
        // _amplitude = Amplitude.getInstance();
        // await _amplitude.init(_amplitudeApiKey);
        print("Amplitude (Web Analytics) SKIPPED FOR NOW.");
      } catch (e) {
        print("Failed to initialize Amplitude: $e");
      }
    } else {
      _firebaseAnalytics = FirebaseAnalytics.instance;
      print("Firebase Analytics (Mobile Analytics) is ready.");
    }
  }

  Future<void> setUserId(String userId) async {
    if (kIsWeb) {
      // await _amplitude.setUserId(userId);
    } else {
      await _firebaseAnalytics.setUserId(id: userId);
    }
  }

  Future<void> logLogin(String userId) async {
    await setUserId(userId);
    if (kIsWeb) {
      // await _amplitude.logEvent('login');
    } else {
      await _firebaseAnalytics.logLogin();
    }
  }

  Future<void> logSignUp(String userId) async {
    await setUserId(userId);
    if (kIsWeb) {
      // await _amplitude.logEvent('sign_up');
    } else {
      await _firebaseAnalytics.logSignUp(signUpMethod: 'email_password');
    }
  }

  Future<void> logEvent(String name,
      {Map<String, dynamic>? parameters}) async {
    if (kIsWeb) {
      // await _amplitude.logEvent(name, eventProperties: parameters);
    } else {
      final Map<String, Object>? firebaseParameters = parameters != null
          ? Map<String, Object>.from(parameters)
          : null;

      await _firebaseAnalytics.logEvent(
        name: name,
        parameters: firebaseParameters,
      );
    }
  }
}

