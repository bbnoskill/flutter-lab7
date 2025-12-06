import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:sentry_flutter/sentry_flutter.dart';

const String _sentryDsn = 'https://504620d7a53f45d0060a5188c85874fa@o4510272782729216.ingest.de.sentry.io/4510272785154128';

class MonitoringService {

  Future<void> init() async {
    if (kIsWeb) {
      try {
        await SentryFlutter.init(
              (options) {
            options.dsn = _sentryDsn;
            options.tracesSampleRate = 1.0;
          },
        );
        print("Sentry (Web Monitoring) initialized.");
      } catch (e) {
        print("Failed to initialize Sentry: $e");
      }
    } else {
      if (!FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(true);
      }
      print("Firebase Crashlytics (Mobile Monitoring) is ready.");
    }
  }

  void testCrash() {
    if (kIsWeb) {
      try {
        print("Sending Sentry test exception...");
        throw Exception('Sentry Test Exception (Web)');
      } catch (exception, stackTrace) {
        Sentry.captureException(
          exception,
          stackTrace: stackTrace,
        );
        print("Sentry test exception sent.");
      }
    } else {
      print("Triggering Firebase Crashlytics native crash...");
      FirebaseCrashlytics.instance.crash();
    }
  }

  Future<void> logError(dynamic exception, StackTrace stackTrace) async {
    if (kIsWeb) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    } else {
      await FirebaseCrashlytics.instance.recordError(
        exception,
        stackTrace,
        fatal: false,
      );
    }
  }
}