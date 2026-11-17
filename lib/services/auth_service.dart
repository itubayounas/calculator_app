import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show PlatformException;
import 'package:google_sign_in/google_sign_in.dart';

import '../models/app_user.dart';
import '../utils/exceptions.dart';

// All the Firebase Auth calls live here. Screens only talk to this class
// and catch our own exception types.
class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthService({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
      : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  // The one stream the app root listens to.
  Stream<AppUser?> get authStateChanges =>
      _auth.authStateChanges().map(_toAppUser);

  AppUser? _toAppUser(User? user) =>
      user == null ? null : AppUser(uid: user.uid, email: user.email);

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    } catch (_) {
      throw const UnknownAuthException();
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    } catch (_) {
      throw const UnknownAuthException();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // on web a popup is the simplest way
        await _auth.signInWithPopup(GoogleAuthProvider());
        return;
      }
      final account = await _googleSignIn.signIn();
      if (account == null) throw const GoogleSignInCancelledException();

      final googleAuth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
    } on AppAuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request') {
        throw const GoogleSignInCancelledException();
      }
      throw _mapError(e);
    } on PlatformException catch (e) {
      if (e.code == 'network_error') throw const NetworkException();
      throw const UnknownAuthException();
    } catch (_) {
      throw const UnknownAuthException();
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    } catch (_) {
      throw const UnknownAuthException();
    }
  }

  Future<void> signOut() async {
    try {
      if (!kIsWeb) await _googleSignIn.signOut();
    } catch (_) {
      // not signed in with Google, nothing to do
    }
    await _auth.signOut();
  }

  // Firebase error code -> our own exception type
  AppAuthException _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return const InvalidEmailException();
      case 'user-not-found':
        return const UserNotFoundException();
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return const WrongCredentialsException();
      case 'email-already-in-use':
        return const EmailAlreadyInUseException();
      case 'weak-password':
        return const WeakPasswordException();
      case 'user-disabled':
        return const UserDisabledException();
      case 'too-many-requests':
        return const TooManyRequestsException();
      case 'network-request-failed':
        return const NetworkException();
      default:
        return const UnknownAuthException();
    }
  }
}
