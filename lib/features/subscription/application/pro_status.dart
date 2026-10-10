import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the active account is on a Pro plan. DUMMY until subscriptions are
/// read from Supabase; always false so Pro locks show.
final isProProvider = Provider<bool>((ref) => false);
