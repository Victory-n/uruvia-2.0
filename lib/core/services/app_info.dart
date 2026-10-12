import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// "1.0.0 (3)" from the installed app.
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.buildNumber.isEmpty ? info.version : '${info.version} (${info.buildNumber})';
});

/// The plain version, "1.0.0", for update checks.
final appVersionNumberProvider = FutureProvider<String>((ref) async => (await PackageInfo.fromPlatform()).version);
