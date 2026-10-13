import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_client.dart';
import '../domain/inventory_models.dart';

abstract class InventoryRepository {
  Future<List<ProductCategory>> categories(String accountId);
  Future<ProductCategory> createCategory(String accountId, String name);
  Future<void> renameCategory(String id, String name);
  Future<void> deleteCategory(String id);

  Future<List<Product>> products(String accountId);
  Future<Product?> product(String id);
  Future<void> createProduct({
    required String accountId,
    required String name,
    required String sku,
    required String unit,
    required int costKobo,
    required int priceKobo,
    required int openingQty,
    required bool lowStockAlert,
    required int lowStockThreshold,
    String? categoryId,
    String? imagePath,
  });
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
    String? imagePath,
  });
  Future<void> setArchived(String id, bool archived);

  Future<List<StockMovement>> movements(String productId);
  Future<List<Reservation>> activeReservations(String productId);

  Future<void> restock(String productId, int qty, String? note);

  /// [reason] is damaged, lost or count. [delta] is signed.
  Future<void> adjust(String productId, int delta, String reason, String? note);
  Future<void> reserve(String productId, int qty, String? note);
  Future<void> release(String reservationId);

  Future<List<RestockReminder>> reminders(String accountId);
  Future<void> createReminder(String accountId, String productId, DateTime remindAt);
  Future<void> deleteReminder(String id);
}

class SupabaseInventoryRepository implements InventoryRepository {
  const SupabaseInventoryRepository();

  @override
  Future<List<ProductCategory>> categories(String accountId) async {
    final rows = await supabase
        .from('product_categories')
        .select('id, name')
        .eq('account_id', accountId)
        .order('name') as List;
    return [for (final r in rows) ProductCategory(id: r['id'] as String, name: r['name'] as String)];
  }

  @override
  Future<ProductCategory> createCategory(String accountId, String name) async {
    final r = await supabase
        .from('product_categories')
        .insert({'account_id': accountId, 'name': name.trim()})
        .select('id, name')
        .single();
    return ProductCategory(id: r['id'] as String, name: r['name'] as String);
  }

  @override
  Future<void> renameCategory(String id, String name) async {
    await supabase.from('product_categories').update({'name': name.trim()}).eq('id', id);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await supabase.from('product_categories').delete().eq('id', id);
  }

  static const _cols =
      'id, account_id, category_id, name, sku, unit, cost_kobo, price_kobo, qty_on_hand, qty_reserved, low_stock_alert, low_stock_threshold, archived_at, image_path';

  Product _product(Map r, Map<String, String> cats) => Product(
        id: r['id'] as String,
        name: r['name'] as String,
        sku: r['sku'] as String,
        unit: r['unit'] as String,
        costKobo: (r['cost_kobo'] as num).toInt(),
        priceKobo: (r['price_kobo'] as num).toInt(),
        qtyOnHand: (r['qty_on_hand'] as num).toInt(),
        qtyReserved: (r['qty_reserved'] as num).toInt(),
        lowStockAlert: r['low_stock_alert'] as bool,
        lowStockThreshold: (r['low_stock_threshold'] as num).toInt(),
        categoryId: r['category_id'] as String?,
        categoryName: cats[r['category_id']],
        archived: r['archived_at'] != null,
        imagePath: r['image_path'] as String?,
      );

  Future<Map<String, String>> _catNames(String accountId) async {
    final list = await categories(accountId);
    return {for (final c in list) c.id: c.name};
  }

  @override
  Future<List<Product>> products(String accountId) async {
    final rows = await supabase
        .from('products')
        .select(_cols)
        .eq('account_id', accountId)
        .isFilter('archived_at', null)
        .order('name')
        .limit(1000) as List;
    if (rows.isEmpty) return const [];
    final cats = await _catNames(accountId);
    return [for (final r in rows) _product(r as Map, cats)];
  }

  @override
  Future<Product?> product(String id) async {
    final row = await supabase.from('products').select(_cols).eq('id', id).maybeSingle();
    if (row == null) return null;
    return _product(row, await _catNames(row['account_id'] as String));
  }

  @override
  Future<void> createProduct({
    required String accountId,
    required String name,
    required String sku,
    required String unit,
    required int costKobo,
    required int priceKobo,
    required int openingQty,
    required bool lowStockAlert,
    required int lowStockThreshold,
    String? categoryId,
    String? imagePath,
  }) async {
    await supabase.from('products').insert({
      'account_id': accountId,
      'category_id': categoryId,
      'name': name.trim(),
      'sku': sku.trim(),
      'unit': unit,
      'cost_kobo': costKobo,
      'price_kobo': priceKobo,
      'qty_on_hand': openingQty,
      'low_stock_alert': lowStockAlert,
      'low_stock_threshold': lowStockThreshold,
      'image_path': imagePath,
    });
  }

  @override
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
    String? imagePath,
  }) async {
    await supabase.from('products').update({
      'category_id': categoryId,
      'name': name.trim(),
      'sku': sku.trim(),
      'unit': unit,
      'cost_kobo': costKobo,
      'price_kobo': priceKobo,
      'low_stock_alert': lowStockAlert,
      'low_stock_threshold': lowStockThreshold,
      'image_path': imagePath,
    }).eq('id', id);
  }

  @override
  Future<void> setArchived(String id, bool archived) async {
    await supabase
        .from('products')
        .update({'archived_at': archived ? DateTime.now().toUtc().toIso8601String() : null}).eq('id', id);
  }

  @override
  Future<List<StockMovement>> movements(String productId) async {
    final rows = await supabase
        .from('stock_movements')
        .select('id, kind, delta_on_hand, delta_reserved, note, created_at')
        .eq('product_id', productId)
        .order('created_at', ascending: false)
        .limit(200) as List;
    return [
      for (final r in rows)
        StockMovement(
          id: r['id'] as String,
          kind: MovementKind.parse(r['kind'] as String),
          deltaOnHand: (r['delta_on_hand'] as num).toInt(),
          deltaReserved: (r['delta_reserved'] as num).toInt(),
          note: r['note'] as String?,
          createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
        ),
    ];
  }

  @override
  Future<List<Reservation>> activeReservations(String productId) async {
    final rows = await supabase
        .from('stock_reservations')
        .select('id, qty, note, invoice_id, reserved_at, expires_at')
        .eq('product_id', productId)
        .eq('status', 'active')
        .order('expires_at') as List;
    return [
      for (final r in rows)
        Reservation(
          id: r['id'] as String,
          qty: (r['qty'] as num).toInt(),
          note: r['note'] as String?,
          invoiceId: r['invoice_id'] as String?,
          reservedAt: DateTime.parse(r['reserved_at'] as String).toLocal(),
          expiresAt: DateTime.parse(r['expires_at'] as String).toLocal(),
        ),
    ];
  }

  @override
  Future<void> restock(String productId, int qty, String? note) async {
    await supabase.rpc('restock_product', params: {'p_product_id': productId, 'p_qty': qty, 'p_note': _clean(note)});
  }

  @override
  Future<void> adjust(String productId, int delta, String reason, String? note) async {
    await supabase.rpc('adjust_product_stock', params: {
      'p_product_id': productId,
      'p_delta': delta,
      'p_reason': reason,
      'p_note': _clean(note),
    });
  }

  @override
  Future<void> reserve(String productId, int qty, String? note) async {
    await supabase.rpc('reserve_product_stock', params: {'p_product_id': productId, 'p_qty': qty, 'p_note': _clean(note)});
  }

  @override
  Future<void> release(String reservationId) async {
    await supabase.rpc('release_product_reservation', params: {'p_reservation_id': reservationId});
  }

  @override
  Future<List<RestockReminder>> reminders(String accountId) async {
    final rows = await supabase
        .from('restock_reminders')
        .select('id, product_id, remind_at, done_at')
        .eq('account_id', accountId)
        .isFilter('done_at', null)
        .order('remind_at') as List;
    return [
      for (final r in rows)
        RestockReminder(
          id: r['id'] as String,
          productId: r['product_id'] as String,
          remindAt: DateTime.parse(r['remind_at'] as String).toLocal(),
        ),
    ];
  }

  @override
  Future<void> createReminder(String accountId, String productId, DateTime remindAt) async {
    await supabase.from('restock_reminders').insert({
      'account_id': accountId,
      'product_id': productId,
      'remind_at': remindAt.toUtc().toIso8601String(),
    });
  }

  @override
  Future<void> deleteReminder(String id) async {
    await supabase.from('restock_reminders').delete().eq('id', id);
  }

  static String? _clean(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();
}

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) => const SupabaseInventoryRepository());
