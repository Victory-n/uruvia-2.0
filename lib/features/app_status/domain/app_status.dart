/// What the app should do at start: carry on, show a maintenance notice, or ask for an update.
enum AppGate { open, maintenance, updateRequired }

class AppStatus {
  const AppStatus({required this.gate, this.message, this.storeUrl});
  final AppGate gate;
  final String? message;
  final String? storeUrl;

  static const open = AppStatus(gate: AppGate.open);
}

/// Compares "1.2.10" with "1.2.9". Negative when [a] is older than [b].
int compareVersions(String a, String b) {
  List<int> parts(String v) => [for (final p in v.split('+').first.split('.')) int.tryParse(p.trim()) ?? 0];
  final x = parts(a), y = parts(b);
  for (var i = 0; i < 3; i++) {
    final xi = i < x.length ? x[i] : 0, yi = i < y.length ? y[i] : 0;
    if (xi != yi) return xi < yi ? -1 : 1;
  }
  return 0;
}

/// [row] is the single app_config row (or null when it could not be read: the app then opens normally).
AppStatus evaluateAppStatus({required Map<String, dynamic>? row, required String installed, required bool isIos}) {
  if (row == null) return AppStatus.open;
  if (row['maintenance'] == true) {
    return AppStatus(gate: AppGate.maintenance, message: row['maintenance_message'] as String?);
  }
  final min = (isIos ? row['min_version_ios'] : row['min_version_android']) as String? ?? '0.0.0';
  if (compareVersions(installed, min) < 0) {
    final url = (isIos ? row['store_url_ios'] : row['store_url_android']) as String?;
    return AppStatus(gate: AppGate.updateRequired, storeUrl: url);
  }
  return AppStatus.open;
}
