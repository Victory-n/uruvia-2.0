import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/application/active_account.dart';
import '../data/customers_repository.dart';
import '../domain/customer_models.dart';

final customersProvider = FutureProvider.autoDispose<List<Customer>>((ref) async {
  final account = ref.watch(activeAccountSummaryProvider);
  if (account == null) return const [];
  return ref.watch(customersRepositoryProvider).customers(account.id);
});

final customerProvider = FutureProvider.autoDispose.family<Customer?, String>(
  (ref, id) => ref.watch(customersRepositoryProvider).customer(id),
);

class CustomerActions {
  CustomerActions(this._ref);
  final Ref _ref;

  CustomersRepository get _repo => _ref.read(customersRepositoryProvider);

  String get _accountId {
    final a = _ref.read(activeAccountSummaryProvider);
    if (a == null) throw StateError('No active account');
    return a.id;
  }

  Future<Customer> create({required String name, String? phone, String? email, String? address, String? notes}) async {
    final c = await _repo.create(_accountId, name: name, phone: phone, email: email, address: address, notes: notes);
    _ref.invalidate(customersProvider);
    return c;
  }

  Future<void> update(String id, {required String name, String? phone, String? email, String? address, String? notes}) async {
    await _repo.update(id, name: name, phone: phone, email: email, address: address, notes: notes);
    _ref.invalidate(customersProvider);
    _ref.invalidate(customerProvider(id));
  }

  Future<void> archive(String id) async {
    await _repo.archive(id);
    _ref.invalidate(customersProvider);
    _ref.invalidate(customerProvider(id));
  }
}

final customerActionsProvider = Provider<CustomerActions>(CustomerActions.new);
