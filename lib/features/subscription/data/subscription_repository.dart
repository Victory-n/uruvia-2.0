import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_client.dart';
import '../domain/plan_models.dart';

abstract class SubscriptionRepository {
  /// The paid plan for an account type, or null when none is set up.
  Future<Plan?> planFor(String accountType);
  Future<Subscription?> current(String accountId);
}

class SupabaseSubscriptionRepository implements SubscriptionRepository {
  const SupabaseSubscriptionRepository();

  @override
  Future<Plan?> planFor(String accountType) async {
    final r = await supabase.from('plans').select().eq('account_type', accountType).limit(1).maybeSingle();
    return r == null ? null : Plan.fromRow(r);
  }

  @override
  Future<Subscription?> current(String accountId) async {
    final r = await supabase
        .from('subscriptions')
        .select('plan_code, status, current_period_end, grace_until')
        .eq('account_id', accountId)
        .inFilter('status', ['active', 'past_due'])
        .maybeSingle();
    return r == null ? null : Subscription.fromRow(r);
  }
}

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) => const SupabaseSubscriptionRepository());
