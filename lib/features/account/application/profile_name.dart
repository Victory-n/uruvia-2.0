import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bootstrap.dart';

/// Name shown in the sidebar, from `profiles.full_name`.
final profileNameProvider = Provider<String>((ref) {
  final name = ref.watch(bootstrapProvider).valueOrNull?.fullName?.trim();
  return (name == null || name.isEmpty) ? 'Your name' : name;
});
