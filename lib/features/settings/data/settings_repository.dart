import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_client.dart';
import '../domain/settings_models.dart';

abstract class SettingsRepository {
  /// kind -> push on or off. A kind with no row is on.
  Future<Map<String, bool>> alertPrefs();
  Future<void> setAlertPref(String kind, bool enabled);

  Future<BusinessDetails> businessDetails(String accountId);
  Future<void> updateBusiness(String accountId, BusinessDetails d);
}

String? _clean(String? v) {
  final t = v?.trim();
  return (t == null || t.isEmpty) ? null : t;
}

class SupabaseSettingsRepository implements SettingsRepository {
  const SupabaseSettingsRepository();

  @override
  Future<Map<String, bool>> alertPrefs() async {
    final rows = await supabase.from('notification_preferences').select('kind, push_enabled') as List;
    return {for (final r in rows) r['kind'] as String: r['push_enabled'] as bool};
  }

  @override
  Future<void> setAlertPref(String kind, bool enabled) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) throw StateError('Not signed in');
    await supabase
        .from('notification_preferences')
        .upsert({'user_id': uid, 'kind': kind, 'push_enabled': enabled}, onConflict: 'user_id,kind');
  }

  @override
  Future<BusinessDetails> businessDetails(String accountId) async {
    final r = await supabase
        .from('business_profiles')
        .select('business_name, category, address, invoice_prefix, vat_rate_bps, payment_details, logo_path')
        .eq('account_id', accountId)
        .single();
    final pay = (r['payment_details'] as Map?) ?? const {};
    return BusinessDetails(
      name: r['business_name'] as String,
      category: r['category'] as String?,
      address: r['address'] as String?,
      invoicePrefix: r['invoice_prefix'] as String,
      vatRateBps: (r['vat_rate_bps'] as num).toInt(),
      bankName: pay['bank_name'] as String?,
      accountNumber: pay['account_number'] as String?,
      accountName: pay['account_name'] as String?,
      logoPath: r['logo_path'] as String?,
    );
  }

  @override
  Future<void> updateBusiness(String accountId, BusinessDetails d) async {
    await supabase.from('business_profiles').update({
      'business_name': d.name.trim(),
      'category': _clean(d.category),
      'address': _clean(d.address),
      'invoice_prefix': d.invoicePrefix.trim(),
      'vat_rate_bps': d.vatRateBps,
      'payment_details': d.paymentDetails,
      'logo_path': d.logoPath,
    }).eq('account_id', accountId);
    // The account carries the same name, shown in the switcher.
    await supabase.from('accounts').update({'name': d.name.trim()}).eq('id', accountId);
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) => const SupabaseSettingsRepository());
