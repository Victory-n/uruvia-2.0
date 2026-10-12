import 'package:flutter_test/flutter_test.dart';
import 'package:uruvia/features/app_status/domain/app_status.dart';

void main() {
  test('compareVersions orders numerically, not as text', () {
    expect(compareVersions('1.2.10', '1.2.9'), 1);
    expect(compareVersions('1.0.0', '1.0.0'), 0);
    expect(compareVersions('0.9.9', '1.0.0'), -1);
    expect(compareVersions('1.0', '1.0.0'), 0);
    expect(compareVersions('1.0.0+5', '1.0.0'), 0);
  });

  test('no config row opens the app', () {
    expect(evaluateAppStatus(row: null, installed: '1.0.0', isIos: false).gate, AppGate.open);
  });

  test('maintenance wins over everything', () {
    final s = evaluateAppStatus(
      row: {'maintenance': true, 'maintenance_message': 'Back at 3pm', 'min_version_android': '9.0.0'},
      installed: '1.0.0',
      isIos: false,
    );
    expect(s.gate, AppGate.maintenance);
    expect(s.message, 'Back at 3pm');
  });

  test('old versions are asked to update, per platform', () {
    final row = {'maintenance': false, 'min_version_android': '2.0.0', 'min_version_ios': '1.0.0', 'store_url_android': 'https://play'};
    final android = evaluateAppStatus(row: row, installed: '1.5.0', isIos: false);
    expect(android.gate, AppGate.updateRequired);
    expect(android.storeUrl, 'https://play');
    expect(evaluateAppStatus(row: row, installed: '1.5.0', isIos: true).gate, AppGate.open);
  });
}
