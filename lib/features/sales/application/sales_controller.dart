import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/application/active_account.dart';
import '../../home/application/home_controller.dart';
import '../../inventory/application/inventory_controller.dart';
import '../data/sales_repository.dart';
import '../domain/sale_models.dart';

final salesProvider = FutureProvider.autoDispose<List<Sale>>((ref) async {
  final account = ref.watch(activeAccountSummaryProvider);
  if (account == null) return const [];
  return ref.watch(salesRepositoryProvider).sales(account.id);
});

final saleProvider = FutureProvider.autoDispose.family<Sale?, String>(
  (ref, id) => ref.watch(salesRepositoryProvider).sale(id),
);

final saleForInvoiceProvider = FutureProvider.autoDispose.family<Sale?, String>(
  (ref, invoiceId) => ref.watch(salesRepositoryProvider).saleForInvoice(invoiceId),
);

final saleItemsProvider = FutureProvider.autoDispose.family<List<SaleItem>, String>(
  (ref, id) => ref.watch(salesRepositoryProvider).items(id),
);

final saleStockEffectsProvider = FutureProvider.autoDispose.family<List<SaleStockEffect>, String>(
  (ref, id) => ref.watch(salesRepositoryProvider).stockEffects(id),
);

final customerSalesProvider = FutureProvider.autoDispose.family<List<Sale>, String>((ref, customerId) async {
  final account = ref.watch(activeAccountSummaryProvider);
  if (account == null) return const [];
  return ref.watch(salesRepositoryProvider).salesForCustomer(account.id, customerId);
});

class SalesActions {
  SalesActions(this._ref);
  final Ref _ref;

  /// Records a counter sale. [items] use the invoice item shape (product_id, description, qty, unit_price_kobo).
  Future<String> recordQuickSale({
    String? customerId,
    required String method,
    String? note,
    required List<Map<String, dynamic>> items,
  }) async {
    final account = _ref.read(activeAccountSummaryProvider);
    if (account == null) throw StateError('No active account');
    final id = await _ref.read(salesRepositoryProvider).recordQuickSale(
          accountId: account.id,
          customerId: customerId,
          method: method,
          note: note,
          items: items,
        );
    _ref.invalidate(salesProvider);
    _ref.invalidate(customerSalesProvider);
    _ref.invalidate(productsProvider);
    _ref.invalidate(productProvider);
    _ref.invalidate(movementsProvider);
    _ref.invalidate(homeDataProvider);
    return id;
  }
}

final salesActionsProvider = Provider<SalesActions>(SalesActions.new);
