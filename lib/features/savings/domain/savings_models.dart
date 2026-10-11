/// DUMMY savings data. Nothing here is saved or sent anywhere.
enum PocketType {
  saveAsYouSpend('save_as_you_spend', 'Save as you spend', 300, Icons_.spend,
      'Set aside a share of every spend automatically.'),
  fixed('fixed', 'Fixed savings', 300, Icons_.fixed, 'Save towards a goal. Add money whenever you like.'),
  locked('locked', 'Locked savings', 1200, Icons_.locked,
      'Lock money away until a date and earn a higher rate.');

  const PocketType(this.db, this.label, this.rateBps, this.iconKey, this.blurb);
  final String db;
  final String label;

  /// Simple interest per year, in basis points (300 = 3%).
  final int rateBps;
  final Icons_ iconKey;
  final String blurb;

  String get rateLabel => '${rateBps ~/ 100}% a year';

  static PocketType parse(String v) =>
      PocketType.values.firstWhere((t) => t.db == v, orElse: () => PocketType.fixed);
}

/// Keeps the domain free of Flutter; the screens map this to an icon.
enum Icons_ { spend, fixed, locked }

enum EntryKind { contribution, withdrawal, interest }

class PocketEntry {
  const PocketEntry({required this.kind, required this.amountKobo, required this.at});
  final EntryKind kind;
  final int amountKobo;
  final DateTime at;

  int get signedKobo => kind == EntryKind.withdrawal ? -amountKobo : amountKobo;
}

class SavingsPocket {
  const SavingsPocket({
    required this.id,
    required this.type,
    required this.name,
    required this.balanceKobo,
    required this.createdAt,
    required this.entries,
    this.targetKobo,
    this.maturesOn,
    this.spendPercent,
  });

  final String id;
  final PocketType type;
  final String name;
  final int balanceKobo;
  final int? targetKobo;
  final DateTime? maturesOn;
  final int? spendPercent;
  final DateTime createdAt;
  final List<PocketEntry> entries;

  /// Locked money cannot leave before the maturity date.
  bool isLocked({DateTime? now}) =>
      type == PocketType.locked && maturesOn != null && (now ?? DateTime.now()).isBefore(maturesOn!);

  /// 0 to 1, or null when there is no target.
  double? get progress {
    final t = targetKobo;
    if (t == null || t <= 0) return null;
    return (balanceKobo / t).clamp(0, 1).toDouble();
  }

  SavingsPocket withEntry(PocketEntry e) => SavingsPocket(
        id: id,
        type: type,
        name: name,
        balanceKobo: balanceKobo + e.signedKobo,
        createdAt: createdAt,
        entries: [e, ...entries],
        targetKobo: targetKobo,
        maturesOn: maturesOn,
        spendPercent: spendPercent,
      );
}

/// Simple interest for [months] on [principalKobo] at [rateBps] a year.
int projectedInterestKobo(int principalKobo, int rateBps, int months) =>
    principalKobo * rateBps * months ~/ 120000;

/// Interest earned so far on [principalKobo] over [days] (simple, 365-day year).
int accruedInterestKobo(int principalKobo, int rateBps, int days) =>
    principalKobo * rateBps * days ~/ (10000 * 365);

/// Adds months and keeps the day inside the target month (31 Jan + 1 month = 28 Feb).
DateTime addMonths(DateTime d, int months) {
  final total = d.month - 1 + months;
  final y = d.year + total ~/ 12;
  final m = total % 12 + 1;
  final last = DateTime(y, m + 1, 0).day;
  return DateTime(y, m, d.day > last ? last : d.day);
}

const lockedMonthOptions = [3, 6, 12];
const spendPercentOptions = [5, 10, 20];

/// Why a new pocket cannot be created, or null.
String? validateNewPocket({
  required PocketType type,
  required String name,
  required int amountKobo,
  int? targetKobo,
  int? months,
  int? spendPercent,
}) {
  if (name.trim().isEmpty) return 'Give the pocket a name.';
  if (name.trim().length > 40) return 'Keep the name under 40 characters.';
  switch (type) {
    case PocketType.saveAsYouSpend:
      if (spendPercent == null) return 'Choose how much to set aside.';
    case PocketType.fixed:
      if (targetKobo != null && targetKobo <= 0) return 'The target must be more than zero.';
    case PocketType.locked:
      if (months == null) return 'Choose how long to lock it.';
      if (amountKobo <= 0) return 'Enter the amount to lock.';
  }
  return null;
}
