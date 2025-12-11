import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:developer';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'core/analytics_service.dart';
import 'core/monitoring_service.dart';
import 'core/app_strings.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';

import 'screens/auth/auth_wrapper.dart';

import 'config/config.dart';

final analyticsService = AnalyticsService();
final monitoringService = MonitoringService();

Future<void> _initializeForEnvironment(String environment) async {
  await AppConfig.initialize(environment);

  if (environment == 'dev') {
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) {
        print('🚀 Initializing Notebook App in DEV mode');
      }
    };
    debugPrint('Initializing in DEV mode');
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb && environment != 'dev') {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    FlutterError.onError = (FlutterErrorDetails details) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  await analyticsService.init();
  await monitoringService.init();
}

void main() async {
  const environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'production',
  );

  WidgetsFlutterBinding.ensureInitialized();

  await _initializeForEnvironment(environment);

  runApp(NotebookApp(environment: environment));
}

class NotebookApp extends StatelessWidget {
  final String environment;

  const NotebookApp({super.key, required this.environment});

  @override
  Widget build(BuildContext context) {
    ColorScheme? colorScheme;
    String appTitle;

    switch (environment) {
      case 'dev':
        colorScheme = ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        );
        appTitle = '${AppStrings.appTitle} (Dev)';
        break;
      case 'staging':
        colorScheme = ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.light,
        );
        appTitle = '${AppStrings.appTitle} (Staging)';
        break;
      default:
        colorScheme = ColorScheme.fromSeed(
          seedColor: Colors.deepOrangeAccent,
          brightness: Brightness.light,
        );
        appTitle = AppStrings.appTitle;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: environment == 'dev',
      title: appTitle,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
      ),
      home: const AuthWrapper(),
    );
  }
}