enum PlanType { free, premium }

class PlanCapabilities {
  final PlanType planType;

  const PlanCapabilities({required this.planType});

  factory PlanCapabilities.fromPlanName(String? planName) {
    if (planName == null) return const PlanCapabilities(planType: PlanType.free);
    final normalized = planName.trim().toLowerCase();
    if (normalized == 'premium' || normalized == 'pro') {
      return const PlanCapabilities(planType: PlanType.premium);
    }
    return const PlanCapabilities(planType: PlanType.free);
  }

  bool get isPremium => planType == PlanType.premium;
  bool get isFree => planType == PlanType.free;

  // Binary Feature Gates
  bool get canAccessBusinessHealth => isPremium;
  bool get canUseOcrScanning => isPremium;
  bool get canUseAutoReminders => isPremium;
  bool get canGenerateStatements => isPremium;

  // Quota Limits (10 contacts on Free plan, Unlimited on Premium)
  int get maxCustomerContacts => isPremium ? 999999999 : 10;
}
