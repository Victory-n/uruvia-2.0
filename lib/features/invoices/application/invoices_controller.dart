import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/application/active_account.dart';
import '../../customers/application/customers_controller.dart';
import '../../home/application/home_controller.dart';
import '../../inventory/application/inventory_controller.dart';
import '../../sales/application/sales_controller.dart';
import '../data/invoices_repository.dart';
import '../domain/invoice_models.dart';

final invoicesProvider = FutureProvider.autoDispose<List<Invoice>>((ref) async {
  final account = ref.watch(activeAccountSummaryProvider);
  if (account == null) return const [];
  return ref.watch(invoicesRepositoryProvider).invoices(account.id);
});

final customerInvoicesProvider = FutureProvider.autoDispose.family<List<Invoice>, String>((ref, customerId) async {
  final account = ref.watch(activeAccountSummaryProvider);
  if (account == null) return const [];
  return ref.watch(invoicesRepositoryProvider).invoicesForCustomer(account.id, customerId);
});

final invoiceProvider = FutureProvider.autoDispose.family<Invoice?, String>(
  (ref, id) => ref.watch(invoicesRepositoryProvider).invoice(id),
);

final invoiceItemsProvider = FutureProvider.autoDispose.family<List<InvoiceItem>, String>(
  (ref, id) => ref.watch(invoicesRepositoryProvider).items(id),
);

final invoicePaymentsProvider = FutureProvider.autoDispose.family<List<InvoicePayment>, String>(
  (ref, id) => ref.watch(invoicesRepositoryProvider).payments(id),
);

final businessInfoProvider = FutureProvider.autoDispose<BusinessInfo?>((ref) async {
  final account = ref.watch(activeAccountSummaryProvider);
  if (account == null) return null;
  return ref.watch(invoicesRepositoryProvider).business(account.id);
});

class InvoiceActions {
  InvoiceActions(this._ref);
  final Ref _ref;

  InvoicesRepository get _repo => _ref.read(invoicesRepositoryProvider);

  String get _accountId {
    final a = _ref.read(activeAccountSummaryProvider);
    if (a == null) throw StateError('No active account');
    return a.id;
  }

  /// Everything an invoice change can affect: lists, stock, sales, the customer's totals and Home.
  void _refresh(String? invoiceId, {bool stock = false, bool sales = false}) {
    _ref.invalidate(invoicesProvider);
    _ref.invalidate(customerInvoicesProvider);
    if (invoiceId != null) {
      _ref.invalidate(invoiceProvider(invoiceId));
      _ref.invalidate(invoiceItemsProvider(invoiceId));
      _ref.invalidate(invoicePaymentsProvider(invoiceId));
    }
    if (stock) {
      _ref.invalidate(productsProvider);
      _ref.invalidate(productProvider);
      _ref.invalidate(reservationsProvider);
      _ref.invalidate(movementsProvider);
    }
    if (sales) {
      _ref.invalidate(salesProvider);
      _ref.invalidate(customerSalesProvider);
    }
    _ref.invalidate(homeDataProvider);
  }

  Future<String> saveDraft({
    String? invoiceId,
    required String customerId,
    required DateTime issueDate,
    required DateTime dueDate,
    required int discountKobo,
    required bool vatEnabled,
    required int chargesKobo,
    String? notes,
    String? terms,
    required List<InvoiceItem> items,
  }) async {
    final id = await _repo.saveDraft(
      accountId: _accountId,
      invoiceId: invoiceId,
      customerId: customerId,
      issueDate: issueDate,
      dueDate: dueDate,
      discountKobo: discountKobo,
      vatEnabled: vatEnabled,
      chargesKobo: chargesKobo,
      notes: notes,
      terms: terms,
      items: items,
    );
    _refresh(id);
    return id;
  }

  Future<void> issue(String id) async {
    await _repo.issue(id);
    _refresh(id, stock: true);
  }

  Future<void> revertToDraft(String id) async {
    await _repo.revertToDraft(id);
    _refresh(id, stock: true);
  }

  Future<void> cancel(String id) async {
    await _repo.cancel(id);
    _refresh(id, stock: true);
  }

  Future<void> recordPayment(
    String id, {
    required int amountKobo,
    required PaymentMethod method,
    required DateTime paidOn,
    String? reference,
    String? proofPath,
  }) async {
    await _repo.recordPayment(id, amountKobo: amountKobo, method: method, paidOn: paidOn, reference: reference, proofPath: proofPath);
    // A payment that clears the balance creates the sale and moves stock out.
    _refresh(id, stock: true, sales: true);
    _ref.invalidate(customersProvider);
  }
}

final invoiceActionsProvider = Provider<InvoiceActions>(InvoiceActions.new);
