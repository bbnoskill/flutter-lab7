import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String _environment = 'production';

  static Future<void> initialize(String environment) async {
    _environment = environment;

    try {
      if (environment == 'dev') {
        await dotenv.load(fileName: '.env.dev');
      } else if (environment == 'staging') {
        await dotenv.load(fileName: '.env.staging');
      } else {
        await dotenv.load(fileName: '.env.prod');
      }

      print('Config loaded for environment: $environment');
      print('API URL: ${apiUrl}');
      print('Debug mode: $isDebug');
    } catch (e) {
      print('Error loading config: $e');
      await dotenv.load(fileName: '.env');
    }
  }

  static String get environment => _environment;

  static String get apiUrl => dotenv.get('API_URL', fallback: 'https://default-api.com');

  static String get firebaseProjectId => dotenv.get('FIREBASE_PROJECT_ID', fallback: '');

  static bool get isDebug => dotenv.get('DEBUG', fallback: 'false') == 'true';

  static String get appName => dotenv.get('APP_NAME', fallback: 'Notebook App');
}