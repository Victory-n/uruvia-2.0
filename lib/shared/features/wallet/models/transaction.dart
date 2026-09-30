class Transaction {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;
  final bool isCredit;

  const Transaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.isCredit,
  });
}

final List<Transaction> mockTransactions = [
  Transaction(
    id: '1',
    title: 'Grocery Shopping',
    subtitle: 'Walmart',
    amount: 154.20,
    date: DateTime.now().subtract(const Duration(hours: 2)),
    isCredit: false,
  ),
  Transaction(
    id: '2',
    title: 'Salary Deposit',
    subtitle: 'Tech Corp Inc.',
    amount: 3200.00,
    date: DateTime.now().subtract(const Duration(days: 1)),
    isCredit: true,
  ),
  Transaction(
    id: '3',
    title: 'Coffee Shop',
    subtitle: 'Starbucks',
    amount: 6.50,
    date: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
    isCredit: false,
  ),
  Transaction(
    id: '4',
    title: 'Electric Bill',
    subtitle: 'Utility Co.',
    amount: 85.00,
    date: DateTime.now().subtract(const Duration(days: 3)),
    isCredit: false,
  ),
  Transaction(
    id: '5',
    title: 'Freelance Work',
    subtitle: 'Upwork',
    amount: 450.00,
    date: DateTime.now().subtract(const Duration(days: 4)),
    isCredit: true,
  ),
];
