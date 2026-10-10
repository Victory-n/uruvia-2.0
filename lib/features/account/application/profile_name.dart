import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Name shown in the sidebar. Replaced by the signed-in user's name
/// (from `profiles.full_name`) when sign-in is built.
final profileNameProvider = Provider<String>((ref) => 'Your name');
