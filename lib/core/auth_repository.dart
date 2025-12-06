import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'app_strings.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseAnalytics _firebaseAnalytics;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseAnalytics? firebaseAnalytics,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firebaseAnalytics = firebaseAnalytics ?? FirebaseAnalytics.instance;

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _firebaseAnalytics.logSignUp(signUpMethod: 'email_password');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception(AppStrings.emailInUse);
      }
      rethrow;
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _firebaseAnalytics.logLogin(loginMethod: 'email_password');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential' ||
          e.code == 'INVALID_LOGIN_CREDENTIALS') {
        throw Exception(AppStrings.errorInvalidCredential);
      } else if (e.code == 'invalid-email') {
        throw Exception(AppStrings.emailInvalidError);
      } else {
        throw Exception(AppStrings.unknownError);
      }
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    _firebaseAnalytics.logEvent(name: 'logout');
  }

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
