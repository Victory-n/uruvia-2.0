import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uruvia/services/plan_capabilities.dart';

// class SubscriptionService {
//   static final SubscriptionService _instance = SubscriptionService._internal();
//   static SubscriptionService get instance => _instance;
//   SubscriptionService._internal();
//
//   PlanCapabilities _capabilities = const PlanCapabilities(
//     planType: PlanType.free,
//   );
//
//   PlanCapabilities get currentCapabilities {
//     _refreshFromUserMetadata();
//     return _capabilities;
//   }
//
//   void _refreshFromUserMetadata() {
//     final user = Supabase.instance.client.auth.currentUser;
//     if (user != null && user.userMetadata != null) {
//       final planName = user.userMetadata!['plan_type'] as String?;
//       _capabilities = PlanCapabilities.fromPlanName(planName);
//     } else {
//       _capabilities = const PlanCapabilities(planType: PlanType.free);
//     }
//   }
//
//   /// Checks if customer directory count is under the allowed quota limit
//   Future<bool> canAddCustomerContact() async {
//     final capabilities = currentCapabilities;
//     if (capabilities.isPremium) return true;
//
//     final customers = await CustomerRepository.instance.getCustomers();
//     return customers.length < capabilities.maxCustomerContacts;
//   }
//
//   /// Returns current number of saved customer contacts
//   Future<int> getCustomerContactCount() async {
//     final customers = await CustomerRepository.instance.getCustomers();
//     return customers.length;
//   }
//
//   /// Manually update plan type in Supabase user metadata (e.g. after successful checkout)
//   Future<bool> updatePlanType(PlanType planType) async {
//     try {
//       final planName = planType == PlanType.premium ? 'premium' : 'free';
//       await Supabase.instance.client.auth.updateUser(
//         UserAttributes(data: {'plan_type': planName}),
//       );
//       _capabilities = PlanCapabilities(planType: planType);
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }
// }
