import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_client.dart';
import '../domain/invoice_models.dart';

abstract class InvoicesRepository {
  Future<List<Invoice>> invoices(String accountId);
  Future<List<Invoice>> invoicesForCustomer(String accountId, String customerId);
  Future<Invoice?> invoice(String id);
  Future<List<InvoiceItem>> items(String invoiceId);
  Future<List<InvoicePayment>> payments(String invoiceId);
  Future<BusinessInfo> business(String accountId);

  /// Creates a draft when [invoiceId] is null, otherwise rewrites the draft. Returns the invoice id.
  Future<String> saveDraft({
    required String accountId,
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
  });
  Future<void> issue(String invoiceId);
  Future<void> revertToDraft(String invoiceId);
  Future<void> cancel(String invoiceId);
  Future<void> recordPayment(
    String invoiceId, {
    required int amountKobo,
    required PaymentMethod method,
    required DateTime paidOn,
    String? reference,
  });
}

String? _clean(String? v) {
  final t = v?.trim();
  return (t == null || t.isEmpty) ? null : t;
}

class SupabaseInvoicesRepository implements InvoicesRepository {
  const SupabaseInvoicesRepository();

  Future<Map<String, String>> _names(Iterable<String> ids) async {
    final unique = ids.toSet().toList();
    if (unique.isEmpty) return const {};
    final rows = await supabase.from('customers').select('id, name').inFilter('id', unique) as List;
    return {for (final c in rows) c['id'] as String: c['name'] as String};
  }

  Future<List<Invoice>> _withNames(List rows) async {
    final names = await _names([for (final r in rows) r['customer_id'] as String]);
    return [for (final r in rows) Invoice.fromRow(r as Map<String, dynamic>, customerName: names[r['customer_id']])];
  }

  @override
  Future<List<Invoice>> invoices(String accountId) async {
    final rows = await supabase
        .from('invoices')
        .select()
        .eq('account_id', accountId)
        .order('created_at', ascending: false) as List;
    return _withNames(rows);
  }

  @override
  Future<List<Invoice>> invoicesForCustomer(String accountId, String customerId) async {
    final rows = await supabase
        .from('invoices')
        .select()
        .eq('account_id', accountId)
        .eq('customer_id', customerId)
        .order('created_at', ascending: false) as List;
    return _withNames(rows);
  }

  @override
  Future<Invoice?> invoice(String id) async {
    final r = await supabase.from('invoices').select().eq('id', id).maybeSingle();
    if (r == null) return null;
    final names = await _names([r['customer_id'] as String]);
    return Invoice.fromRow(r, customerName: names[r['customer_id']]);
  }

  @override
  Future<List<InvoiceItem>> items(String invoiceId) async {
    final rows = await supabase.from('invoice_items').select().eq('invoice_id', invoiceId).order('sort_order') as List;
    return [for (final r in rows) InvoiceItem.fromRow(r as Map<String, dynamic>)];
  }

  @override
  Future<List<InvoicePayment>> payments(String invoiceId) async {
    final rows = await supabase
        .from('invoice_payments')
        .select('id, amount_kobo, method, paid_on, reference')
        .eq('invoice_id', invoiceId)
        .order('created_at', ascending: false) as List;
    return [
      for (final r in rows)
        InvoicePayment(
          id: r['id'] as String,
          amountKobo: (r['amount_kobo'] as num).toInt(),
          method: PaymentMethod.parse(r['method'] as String),
          paidOn: DateTime.parse(r['paid_on'] as String),
          reference: r['reference'] as String?,
        ),
    ];
  }

  @override
  Future<BusinessInfo> business(String accountId) async {
    final r = await supabase
        .from('business_profiles')
        .select('business_name, address, vat_rate_bps, payment_details')
        .eq('account_id', accountId)
        .single();
    final pay = (r['payment_details'] as Map?) ?? const {};
    return BusinessInfo(
      name: r['business_name'] as String,
      address: r['address'] as String?,
      vatRateBps: (r['vat_rate_bps'] as num).toInt(),
      bankName: pay['bank_name'] as String?,
      accountNumber: pay['account_number'] as String?,
      accountName: pay['account_name'] as String?,
    );
  }

  @override
  Future<String> saveDraft({
    required String accountId,
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
    final id = await supabase.rpc('save_invoice_draft', params: {
      'p_account_id': accountId,
      'p_invoice_id': invoiceId,
      'p_customer_id': customerId,
      'p_issue_date': isoDate(issueDate),
      'p_due_date': isoDate(dueDate),
      'p_discount_kobo': discountKobo,
      'p_vat_enabled': vatEnabled,
      'p_charges_kobo': chargesKobo,
      'p_notes': _clean(notes),
      'p_terms': _clean(terms),
      'p_items': [for (final i in items) i.toJson()],
    });
    return id as String;
  }

  @override
  Future<void> issue(String invoiceId) async {
    await supabase.rpc('issue_invoice', params: {'p_invoice_id': invoiceId});
  }

  @override
  Future<void> revertToDraft(String invoiceId) async {
    await supabase.rpc('revert_invoice_to_draft', params: {'p_invoice_id': invoiceId});
  }

  @override
  Future<void> cancel(String invoiceId) async {
    await supabase.rpc('cancel_invoice', params: {'p_invoice_id': invoiceId});
  }

  @override
  Future<void> recordPayment(
    String invoiceId, {
    required int amountKobo,
    required PaymentMethod method,
    required DateTime paidOn,
    String? reference,
  }) async {
    await supabase.rpc('record_invoice_payment', params: {
      'p_invoice_id': invoiceId,
      'p_amount_kobo': amountKobo,
      'p_method': method.db,
      'p_paid_on': isoDate(paidOn),
      'p_reference': _clean(reference),
    });
  }
}

final invoicesRepositoryProvider = Provider<InvoicesRepository>((ref) => const SupabaseInvoicesRepository());
