import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/application/active_account.dart';
import '../../home/application/home_controller.dart';
import '../data/inventory_repository.dart';
import '../domain/inventory_models.dart';

final productCategoriesProvider = FutureProvider.autoDispose<List<ProductCategory>>((ref) async {
  final account = ref.watch(activeAccountSummaryProvider);
  if (account == null) return const [];
  return ref.watch(inventoryRepositoryProvider).categories(account.id);
});

final productsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final account = ref.watch(activeAccountSummaryProvider);
  if (account == null) return const [];
  return ref.watch(inventoryRepositoryProvider).products(account.id);
});

final productProvider = FutureProvider.autoDispose.family<Product?, String>(
  (ref, id) => ref.watch(inventoryRepositoryProvider).product(id),
);

final movementsProvider = FutureProvider.autoDispose.family<List<StockMovement>, String>(
  (ref, productId) => ref.watch(inventoryRepositoryProvider).movements(productId),
);

final reservationsProvider = FutureProvider.autoDispose.family<List<Reservation>, String>(
  (ref, productId) => ref.watch(inventoryRepositoryProvider).activeReservations(productId),
);

final remindersProvider = FutureProvider.autoDispose<List<RestockReminder>>((ref) async {
  final account = ref.watch(activeAccountSummaryProvider);
  if (account == null) return const [];
  return ref.watch(inventoryRepositoryProvider).reminders(account.id);
});

class InventoryActions {
  InventoryActions(this._ref);
  final Ref _ref;

  InventoryRepository get _repo => _ref.read(inventoryRepositoryProvider);

  String get _accountId {
    final a = _ref.read(activeAccountSummaryProvider);
    if (a == null) throw StateError('No active account');
    return a.id;
  }

  void _refreshProduct(String productId) {
    _ref.invalidate(productsProvider);
    _ref.invalidate(productProvider(productId));
    _ref.invalidate(movementsProvider(productId));
    _ref.invalidate(reservationsProvider(productId));
    _ref.invalidate(homeDataProvider);
  }

  Future<void> createProduct({
    required String name,
    required String sku,
    required String unit,
    required int costKobo,
    required int priceKobo,
    required int openingQty,
    required bool lowStockAlert,
    required int lowStockThreshold,
    String? categoryId,
  }) async {
    await _repo.createProduct(
      accountId: _accountId,
      name: name,
      sku: sku.trim().isEmpty ? suggestSku(name) : sku,
      unit: unit,
      costKobo: costKobo,
      priceKobo: priceKobo,
      openingQty: openingQty,
      lowStockAlert: lowStockAlert,
      lowStockThreshold: lowStockThreshold,
      categoryId: categoryId,
    );
    _ref.invalidate(productsProvider);
    _ref.invalidate(homeDataProvider);
  }

  Future<void> updateProduct(
    String id, {
    required String name,
    required String sku,
    required String unit,
    required int costKobo,
    required int priceKobo,
    required bool lowStockAlert,
    required int lowStockThreshold,
    String? categoryId,
  }) async {
    await _repo.updateProduct(
      id,
      name: name,
      sku: sku.trim().isEmpty ? suggestSku(name) : sku,
      unit: unit,
      costKobo: costKobo,
      priceKobo: priceKobo,
      lowStockAlert: lowStockAlert,
      lowStockThreshold: lowStockThreshold,
      categoryId: categoryId,
    );
    _refreshProduct(id);
  }

  Future<void> archive(String id) async {
    await _repo.setArchived(id, true);
    _refreshProduct(id);
  }

  Future<void> restock(String id, int qty, String? note) async {
    await _repo.restock(id, qty, note);
    _refreshProduct(id);
  }

  Future<void> adjust(String id, int delta, String reason, String? note) async {
    await _repo.adjust(id, delta, reason, note);
    _refreshProduct(id);
  }

  Future<void> reserve(String id, int qty, String? note) async {
    await _repo.reserve(id, qty, note);
    _refreshProduct(id);
  }

  Future<void> release(String productId, String reservationId) async {
    await _repo.release(reservationId);
    _refreshProduct(productId);
  }

  Future<ProductCategory> addCategory(String name) async {
    final c = await _repo.createCategory(_accountId, name);
    _ref.invalidate(productCategoriesProvider);
    return c;
  }

  Future<void> renameCategory(String id, String name) async {
    await _repo.renameCategory(id, name);
    _ref.invalidate(productCategoriesProvider);
    _ref.invalidate(productsProvider);
  }

  Future<void> deleteCategory(String id) async {
    await _repo.deleteCategory(id);
    _ref.invalidate(productCategoriesProvider);
  }

  Future<void> addReminder(String productId, DateTime when) async {
    await _repo.createReminder(_accountId, productId, when);
    _ref.invalidate(remindersProvider);
  }

  Future<void> removeReminder(String id) async {
    await _repo.deleteReminder(id);
    _ref.invalidate(remindersProvider);
  }
}

final inventoryActionsProvider = Provider<InventoryActions>(InventoryActions.new);
