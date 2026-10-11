import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'subscription_controller.dart';

/// Whether the active account has Pro. The database decides what is locked; this only drives badges and prompts.
final isProProvider = Provider<bool>((ref) => ref.watch(subscriptionProvider).valueOrNull?.isLive() ?? false);
