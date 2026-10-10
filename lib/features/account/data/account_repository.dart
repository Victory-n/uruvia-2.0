import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_client.dart';
import '../domain/account_models.dart';
import '../domain/account_type.dart';

abstract class AccountRepository {
  Future<Bootstrap> load();
  Future<void> createIndividual(String name);
  Future<void> createBusiness(BusinessSetup setup);
  Future<void> setTransactionPin(String pin);
}

class SupabaseAccountRepository implements AccountRepository {
  const SupabaseAccountRepository();

  @override
  Future<Bootstrap> load() async {
    final uid = supabase.auth.currentUser!.id;
    final profile = await supabase
        .from('profiles')
        .select('full_name, last_active_account_id')
        .eq('id', uid)
        .maybeSingle();
    final rows = await supabase.from('accounts').select('id, type, name').order('created_at');
    final hasPin = await supabase.rpc('has_transaction_pin') as bool;

    return Bootstrap(
      fullName: profile?['full_name'] as String?,
      activeAccountId: profile?['last_active_account_id'] as String?,
      hasTransactionPin: hasPin,
      accounts: [
        for (final r in rows as List)
          AccountSummary(
            id: r['id'] as String,
            type: r['type'] == 'business' ? AccountType.business : AccountType.individual,
            name: r['name'] as String,
          ),
      ],
    );
  }

  @override
  Future<void> createIndividual(String name) async {
    await supabase.rpc('create_account', params: {'p_type': 'individual', 'p_name': name});
  }

  @override
  Future<void> createBusiness(BusinessSetup s) async {
    await supabase.rpc('create_business_account', params: {
      'p_name': s.name.trim(),
      'p_category': s.category,
      'p_address': s.address?.trim(),
      'p_invoice_prefix': s.invoicePrefix.trim(),
      'p_vat_rate_bps': s.vatRateBps,
      'p_payment_details': s.paymentDetails,
    });
  }

  @override
  Future<void> setTransactionPin(String pin) async {
    await supabase.rpc('set_transaction_pin', params: {'p_pin': pin});
  }
}

final accountRepositoryProvider = Provider<AccountRepository>((ref) => const SupabaseAccountRepository());
