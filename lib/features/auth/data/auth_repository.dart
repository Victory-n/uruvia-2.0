import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_client.dart';

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

  Future<void> signOut();
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

  @override
  Future<void> signOut() => _auth.signOut();
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => const SupabaseAuthRepository());

/// The current Supabase session (null when signed out).
final sessionProvider = StreamProvider<Session?>((ref) async* {
  final repo = ref.watch(authRepositoryProvider);
  yield repo.currentSession;
  yield* repo.sessionChanges;
});
