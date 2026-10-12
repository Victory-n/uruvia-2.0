import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/app_info.dart';
import '../../../core/services/supabase_client.dart';
import '../domain/app_status.dart';

/// Reads app_config once at start. Any failure (offline, slow) opens the app normally.
final appStatusProvider = FutureProvider<AppStatus>((ref) async {
  try {
    final row = await supabase.from('app_config').select().maybeSingle().timeout(const Duration(seconds: 5));
    final installed = await ref.watch(appVersionNumberProvider.future);
    return evaluateAppStatus(row: row, installed: installed, isIos: Platform.isIOS);
  } catch (_) {
    return AppStatus.open;
  }
});
