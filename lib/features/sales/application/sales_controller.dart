import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/application/active_account.dart';
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

final customerSalesProvider = FutureProvider.autoDispose.family<List<Sale>, String>((ref, customerId) async {
  final account = ref.watch(activeAccountSummaryProvider);
  if (account == null) return const [];
  return ref.watch(salesRepositoryProvider).salesForCustomer(account.id, customerId);
});
