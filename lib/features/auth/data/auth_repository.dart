import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/env.dart';
import '../../../core/services/supabase_client.dart';

/// Thrown when Google or Apple sign-in cannot start; the message is safe to show.
class SocialSignInUnavailable implements Exception {
  const SocialSignInUnavailable(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Everything the app needs from Supabase Auth. Screens never touch it directly.
abstract class AuthRepository {
  Session? get currentSession;
  Stream<Session?> get sessionChanges;

  Future<void> signIn(String email, String password);

  /// Returns true when the user still has to confirm the email with a code.
  Future<bool> signUp({required String fullName, required String email, required String password});
  Future<void> verifySignUpCode(String email, String code);
  Future<void> resendSignUpCode(String email);

  Future<void> sendResetCode(String email);
  Future<void> resetPassword({required String email, required String code, required String newPassword});

  /// Returns false when the user closed the Google or Apple sheet without choosing.
  Future<bool> signInWithGoogle();
  Future<bool> signInWithApple();

  Future<void> signOut();

  /// Ends the session on this phone only (the server session no longer exists after deletion).
  Future<void> signOutLocal();
}

class SupabaseAuthRepository implements AuthRepository {
  const SupabaseAuthRepository();

  GoTrueClient get _auth => supabase.auth;

  @override
  Session? get currentSession => _auth.currentSession;

  @override
  Stream<Session?> get sessionChanges => _auth.onAuthStateChange.map((e) => e.session);

  @override
  Future<void> signIn(String email, String password) async {
    await _auth.signInWithPassword(email: email.trim(), password: password);
  }

  @override
  Future<bool> signUp({required String fullName, required String email, required String password}) async {
    final res = await _auth.signUp(
      email: email.trim(),
      password: password,
      data: {'full_name': fullName.trim()},
    );
    return res.session == null;
  }

  @override
  Future<void> verifySignUpCode(String email, String code) async {
    await _auth.verifyOTP(email: email.trim(), token: code.trim(), type: OtpType.signup);
  }

  @override
  Future<void> resendSignUpCode(String email) async {
    await _auth.resend(type: OtpType.signup, email: email.trim());
  }

  @override
  Future<void> sendResetCode(String email) async {
    await _auth.resetPasswordForEmail(email.trim());
  }

  @override
  Future<void> resetPassword({required String email, required String code, required String newPassword}) async {
    await _auth.verifyOTP(email: email.trim(), token: code.trim(), type: OtpType.recovery);
    await _auth.updateUser(UserAttributes(password: newPassword));
  }

  static bool _googleReady = false;

  @override
  Future<bool> signInWithGoogle() async {
    if (Env.googleWebClientId.isEmpty) throw const SocialSignInUnavailable('Google sign-in is not set up yet.');
    final google = GoogleSignIn.instance;
    if (!_googleReady) {
      await google.initialize(serverClientId: Env.googleWebClientId);
      _googleReady = true;
    }
    try {
      final account = await google.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) throw const SocialSignInUnavailable('Google did not return a sign-in token.');
      await _auth.signInWithIdToken(provider: OAuthProvider.google, idToken: idToken);
      return true;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return false;
      rethrow;
    }
  }

  @override
  Future<bool> signInWithApple() async {
    final raw = _nonce();
    final hashed = sha256.convert(utf8.encode(raw)).toString();
    try {
      final cred = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
        nonce: hashed,
      );
      final token = cred.identityToken;
      if (token == null) throw const SocialSignInUnavailable('Apple did not return a sign-in token.');
      await _auth.signInWithIdToken(provider: OAuthProvider.apple, idToken: token, nonce: raw);
      // Apple shares the name only the first time, so save it now.
      final name = [cred.givenName, cred.familyName].whereType<String>().join(' ').trim();
      final uid = _auth.currentUser?.id;
      if (name.isNotEmpty && uid != null) {
        await supabase.from('profiles').update({'full_name': name}).eq('id', uid);
      }
      return true;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return false;
      rethrow;
    }
  }

  static String _nonce([int length = 32]) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._';
    final r = Random.secure();
    return List.generate(length, (_) => chars[r.nextInt(chars.length)]).join();
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> signOutLocal() => _auth.signOut(scope: SignOutScope.local);
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => const SupabaseAuthRepository());

/// The current Supabase session (null when signed out).
final sessionProvider = StreamProvider<Session?>((ref) async* {
  final repo = ref.watch(authRepositoryProvider);
  yield repo.currentSession;
  yield* repo.sessionChanges;
});
