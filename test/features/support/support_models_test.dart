import 'package:flutter_test/flutter_test.dart';
import 'package:uruvia/features/support/domain/support_models.dart';

void main() {
  test('TicketStatus.parse maps database values and defaults to open', () {
    expect(TicketStatus.parse('in_progress'), TicketStatus.inProgress);
    expect(TicketStatus.parse('resolved'), TicketStatus.resolved);
    expect(TicketStatus.parse('weird'), TicketStatus.open);
  });

  test('validateSupportText checks empty and too long text', () {
    expect(validateSupportText('   '), isNotNull);
    expect(validateSupportText('Help me'), isNull);
    expect(validateSupportText('a' * 5000), isNotNull);
  });
}
