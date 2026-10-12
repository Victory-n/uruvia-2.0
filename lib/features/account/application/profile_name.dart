import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bootstrap.dart';

/// Name shown in the sidebar, from `profiles.full_name`.
final profileNameProvider = Provider<String>((ref) {
  final name = ref.watch(bootstrapProvider).valueOrNull?.fullName?.trim();
  return (name == null || name.isEmpty) ? 'Your name' : name;
});

/// Stored path of the profile picture in the avatars bucket, if one was added.
final profileAvatarProvider = Provider<String?>((ref) => ref.watch(bootstrapProvider).valueOrNull?.avatarPath);
