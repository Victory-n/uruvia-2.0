import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/application/active_account.dart';
import '../data/support_repository.dart';
import '../domain/support_models.dart';

final ticketsProvider = FutureProvider.autoDispose<List<SupportTicket>>(
  (ref) => ref.watch(supportRepositoryProvider).tickets(),
);

final ticketProvider = FutureProvider.autoDispose.family<SupportTicket?, String>(
  (ref, id) => ref.watch(supportRepositoryProvider).ticket(id),
);

final ticketMessagesProvider = FutureProvider.autoDispose.family<List<SupportMessage>, String>(
  (ref, id) => ref.watch(supportRepositoryProvider).messages(id),
);

class SupportActions {
  SupportActions(this._ref);
  final Ref _ref;

  SupportRepository get _repo => _ref.read(supportRepositoryProvider);

  Future<String> create({required String category, required String description}) async {
    final id = await _repo.createTicket(
      accountId: _ref.read(activeAccountSummaryProvider)?.id,
      category: category,
      description: description,
    );
    _ref.invalidate(ticketsProvider);
    return id;
  }

  Future<void> reply(String ticketId, String body) async {
    await _repo.reply(ticketId, body);
    _ref.invalidate(ticketMessagesProvider(ticketId));
  }

  Future<void> resolve(String ticketId) async {
    await _repo.resolve(ticketId);
    _ref.invalidate(ticketProvider(ticketId));
    _ref.invalidate(ticketsProvider);
  }
}

final supportActionsProvider = Provider<SupportActions>(SupportActions.new);
