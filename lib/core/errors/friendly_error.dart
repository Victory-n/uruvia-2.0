import 'package:supabase_flutter/supabase_flutter.dart';

/// Turns any error into a short message a user can act on.
/// Never shows raw server text, stack traces or table names.
String friendlyError(Object error) {
  final raw = error.toString().toLowerCase();

  if (raw.contains('socketexception') ||
      raw.contains('failed host lookup') ||
      raw.contains('clientexception') ||
      raw.contains('timeoutexception') ||
      raw.contains('network is unreachable')) {
    return 'No internet connection. Check your network and try again.';
  }

  if (error is AuthException) {
    final m = error.message.toLowerCase();
    final code = (error.code ?? '').toLowerCase();
    if (m.contains('invalid login') || code == 'invalid_credentials') {
      return 'Email or password is not correct.';
    }
    if (m.contains('not confirmed') || code == 'email_not_confirmed') {
      return 'Please confirm your email first.';
    }
    if (m.contains('already registered') || code == 'user_already_exists') {
      return 'An account with this email already exists. Try signing in.';
    }
    if (m.contains('rate limit') || code.contains('rate_limit') || error.statusCode == '429') {
      return 'Too many tries. Wait a minute and try again.';
    }
    if (m.contains('expired') || m.contains('invalid') && m.contains('token') || code == 'otp_expired') {
      return 'That code is wrong or has expired. Request a new one.';
    }
    if (m.contains('weak') || code == 'weak_password') {
      return 'Choose a stronger password: at least 8 characters with letters and numbers.';
    }
    if (m.contains('same password') || code == 'same_password') {
      return 'Choose a password you have not used before.';
    }
    return 'We could not complete that. Please try again.';
  }

  if (error is PostgrestException) {
    if (error.message.toLowerCase().contains('pin locked')) {
      return 'Too many wrong PIN tries. Try again in 15 minutes.';
    }
    if (error.code == '23505') return 'That already exists.';
    if (error.code == '23503') return 'That is still in use, so it cannot be removed.';
    // Messages written by our own database functions are plain and safe to show.
    final ours = _ownMessage(error.message);
    if (ours != null && (error.code == '55000' || error.code == '23514' || error.code == '22023')) return ours;
    if (error.code == '23514') {
      // Our own stock messages start with "Only N available" and are safe to show.
      if (error.message.startsWith('Only ')) return error.message;
      return 'That would take stock below zero or below what is reserved.';
    }
    return 'Something went wrong on our side. Please try again.';
  }

  return 'Something went wrong. Please try again.';
}

const _ownPrefixes = [
  'add at least one item',
  'amount is more than the balance',
  'amount must be above zero',
  'due date cannot be before',
  'this customer still has unpaid invoices',
  'an invoice can only be edited',
  'only a draft can be issued',
  'payments can only be recorded',
  'this invoice cannot be cancelled',
  'this invoice can no longer be edited',
  'items can only change',
];

/// The database message with a capital letter and a full stop, when it is one of ours.
String? _ownMessage(String message) {
  final m = message.trim();
  final lower = m.toLowerCase();
  if (!_ownPrefixes.any(lower.startsWith)) return null;
  if (lower.startsWith('amount is more than the balance')) return 'That is more than the balance still owing.';
  final capped = m[0].toUpperCase() + m.substring(1);
  return capped.endsWith('.') ? capped : '$capped.';
}
