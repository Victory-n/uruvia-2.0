import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_client.dart';
import '../domain/sale_models.dart';

abstract class SalesRepository {
  Future<List<Sale>> sales(String accountId);
  Future<List<Sale>> salesForCustomer(String accountId, String customerId);
  Future<Sale?> sale(String id);
  Future<Sale?> saleForInvoice(String invoiceId);
  Future<List<SaleItem>> items(String saleId);

  /// Records a counter sale in one step and returns its id.
  Future<String> recordQuickSale({
    required String accountId,
    String? customerId,
    required String method,
    String? note,
    required List<Map<String, dynamic>> items,
  });
}

class SupabaseSalesRepository implements SalesRepository {
  const SupabaseSalesRepository();

  Future<List<Sale>> _withNames(List rows) async {
    final ids = {for (final r in rows) if (r['customer_id'] != null) r['customer_id'] as String}.toList();
    final names = <String, String>{};
    if (ids.isNotEmpty) {
      final cs = await supabase.from('customers').select('id, name').inFilter('id', ids) as List;
      for (final c in cs) {
        names[c['id'] as String] = c['name'] as String;
      }
    }
    return [for (final r in rows) Sale.fromRow(r as Map<String, dynamic>, customerName: names[r['customer_id']])];
  }

  @override
  Future<List<Sale>> sales(String accountId) async {
    final rows = await supabase.from('sales').select().eq('account_id', accountId).order('sold_at', ascending: false) as List;
    return _withNames(rows);
  }

  @override
  Future<List<Sale>> salesForCustomer(String accountId, String customerId) async {
    final rows = await supabase
        .from('sales')
        .select()
        .eq('account_id', accountId)
        .eq('customer_id', customerId)
        .order('sold_at', ascending: false) as List;
    return _withNames(rows);
  }

  @override
  Future<Sale?> sale(String id) async {
    final r = await supabase.from('sales').select().eq('id', id).maybeSingle();
    if (r == null) return null;
    final list = await _withNames([r]);
    return list.first;
  }

  @override
  Future<Sale?> saleForInvoice(String invoiceId) async {
    final r = await supabase.from('sales').select().eq('invoice_id', invoiceId).maybeSingle();
    if (r == null) return null;
    final list = await _withNames([r]);
    return list.first;
  }

  @override
  Future<String> recordQuickSale({
    required String accountId,
    String? customerId,
    required String method,
    String? note,
    required List<Map<String, dynamic>> items,
  }) =>
      supabase.rpc('record_quick_sale', params: {
        'p_account_id': accountId,
        'p_customer_id': customerId,
        'p_method': method,
        'p_note': note,
        'p_items': items,
      }).then((id) => id as String);

  @override
  Future<List<SaleItem>> items(String saleId) async {
    final rows = await supabase.from('sale_items').select().eq('sale_id', saleId) as List;
    return [
      for (final r in rows)
        SaleItem(
          productId: r['product_id'] as String?,
          description: r['description'] as String,
          qty: (r['qty'] as num).toInt(),
          unitPriceKobo: (r['unit_price_kobo'] as num).toInt(),
          unitCostKobo: (r['unit_cost_kobo'] as num).toInt(),
        ),
    ];
  }
}

final salesRepositoryProvider = Provider<SalesRepository>((ref) => const SupabaseSalesRepository());
