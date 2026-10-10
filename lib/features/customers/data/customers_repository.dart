import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_client.dart';
import '../domain/customer_models.dart';

abstract class CustomersRepository {
  Future<List<Customer>> customers(String accountId);
  Future<Customer?> customer(String id);
  Future<Customer> create(String accountId, {required String name, String? phone, String? email, String? address, String? notes});
  Future<void> update(String id, {required String name, String? phone, String? email, String? address, String? notes});

  /// Fails with a friendly message while the customer still has unpaid invoices.
  Future<void> archive(String id);
}

String? _clean(String? v) {
  final t = v?.trim();
  return (t == null || t.isEmpty) ? null : t;
}

class SupabaseCustomersRepository implements CustomersRepository {
  const SupabaseCustomersRepository();

  static const _cols = 'id, name, phone, email, address, notes, archived_at';

  @override
  Future<List<Customer>> customers(String accountId) async {
    final rows = await supabase
        .from('customers')
        .select(_cols)
        .eq('account_id', accountId)
        .isFilter('archived_at', null)
        .order('name') as List;
    return [for (final r in rows) Customer.fromRow(r as Map<String, dynamic>)];
  }

  @override
  Future<Customer?> customer(String id) async {
    final r = await supabase.from('customers').select(_cols).eq('id', id).maybeSingle();
    return r == null ? null : Customer.fromRow(r);
  }

  @override
  Future<Customer> create(String accountId,
      {required String name, String? phone, String? email, String? address, String? notes}) async {
    final r = await supabase
        .from('customers')
        .insert({
          'account_id': accountId,
          'name': name.trim(),
          'phone': _clean(phone),
          'email': _clean(email),
          'address': _clean(address),
          'notes': _clean(notes),
        })
        .select(_cols)
        .single();
    return Customer.fromRow(r);
  }

  @override
  Future<void> update(String id,
      {required String name, String? phone, String? email, String? address, String? notes}) async {
    await supabase.from('customers').update({
      'name': name.trim(),
      'phone': _clean(phone),
      'email': _clean(email),
      'address': _clean(address),
      'notes': _clean(notes),
    }).eq('id', id);
  }

  @override
  Future<void> archive(String id) async {
    await supabase.rpc('archive_customer', params: {'p_customer_id': id});
  }
}

final customersRepositoryProvider = Provider<CustomersRepository>((ref) => const SupabaseCustomersRepository());
