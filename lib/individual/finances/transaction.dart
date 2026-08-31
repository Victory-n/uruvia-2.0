import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/services/currency_service.dart';
import '../../shared/widgets/custom_text.dart';

class IndividualTransactionPage extends StatefulWidget {
  const IndividualTransactionPage({super.key});

  @override
  State<IndividualTransactionPage> createState() =>
      _IndividualTransactionPageState();
}

typedef TransactionPage = IndividualTransactionPage;

class _IndividualTransactionPageState extends State<IndividualTransactionPage> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _mockTransactions = [
    {
      'title': 'Salary Deposit',
      'category': 'Income',
      'date': 'Today, 10:30 AM',
      'amount': 350000.00,
      'currency': 'NGN',
      'isIncome': true,
      'icon': Icons.arrow_downward_rounded,
      'color': Colors.green,
    },
    {
      'title': 'Grocery Store',
      'category': 'Food & Dining',
      'date': 'Yesterday, 4:15 PM',
      'amount': -18500.00,
      'currency': 'NGN',
      'isIncome': false,
      'icon': Icons.shopping_bag_outlined,
      'color': Colors.orange,
    },
    {
      'title': 'Electricity Bill',
      'category': 'Utilities',
      'date': '04 Aug 2026',
      'amount': -12000.00,
      'currency': 'NGN',
      'isIncome': false,
      'icon': Icons.bolt_outlined,
      'color': Colors.redAccent,
    },
    {
      'title': 'Freelance Payment',
      'category': 'Income',
      'date': '02 Aug 2026',
      'amount': 75000.00,
      'currency': 'NGN',
      'isIncome': true,
      'icon': Icons.work_outline,
      'color': Colors.green,
    },
    {
      'title': 'Streaming Subscription',
      'category': 'Entertainment',
      'date': '01 Aug 2026',
      'amount': -4500.00,
      'currency': 'NGN',
      'isIncome': false,
      'icon': Icons.movie_outlined,
      'color': Colors.purple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredList = _selectedFilter == 'All'
        ? _mockTransactions
        : _selectedFilter == 'Income'
        ? _mockTransactions.where((t) => t['isIncome'] == true).toList()
        : _mockTransactions.where((t) => t['isIncome'] == false).toList();

    return Scaffold(
      backgroundColor: ConstantColor.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: Builder(
          builder: (scaffoldContext) => IconButton(
            icon: const Icon(
              Icons.menu,
              color: ConstantColor.headingTextPrimary,
            ),
            onPressed: () {
              Scaffold.of(scaffoldContext).openDrawer();
            },
          ),
        ),
        title: googleSansText(
          text: "Transactions",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 18.0,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search_rounded,
              color: ConstantColor.headingTextPrimary,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.filter_list_rounded,
              color: ConstantColor.headingTextPrimary,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 12.0,
            ),
            child: Row(
              children: ['All', 'Income', 'Expenses'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: googleSansText(
                      text: filter,
                      colors: isSelected
                          ? Colors.white
                          : ConstantColor.paragraphTextPrimary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      size: 13.0,
                    ),
                    selected: isSelected,
                    selectedColor: ConstantColor.blueBackground,
                    backgroundColor: const Color(0xFFF0F4FA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedFilter = filter);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Transactions List
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              itemCount: filteredList.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 12.0),
              itemBuilder: (context, index) {
                final item = filteredList[index];
                final bool isIncome = item['isIncome'];

                return Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: (item['color'] as Color).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: item['color'] as Color,
                          size: 20.0,
                        ),
                      ),
                      const SizedBox(width: 14.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            googleSansText(
                              text: item['title'],
                              colors: ConstantColor.headingTextPrimary,
                              fontWeight: FontWeight.bold,
                              size: 14.5,
                            ),
                            const SizedBox(height: 3.0),
                            googleSansText(
                              text: "${item['category']} • ${item['date']}",
                              colors: ConstantColor.paragraphTextSecondary,
                              fontWeight: FontWeight.normal,
                              size: 12.0,
                            ),
                          ],
                        ),
                      ),
                      googleSansText(
                        text: CurrencyService.format(
                          item['amount'] as num,
                          currency: item['currency'] as String?,
                          showSign: true,
                        ),
                        colors: isIncome
                            ? Colors.green
                            : ConstantColor.headingTextPrimary,
                        fontWeight: FontWeight.bold,
                        size: 14.5,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: ConstantColor.blueBackground,
        icon: const Icon(Icons.add, color: Colors.white),
        label: googleSansText(
          text: "Add Transaction",
          colors: Colors.white,
          fontWeight: FontWeight.bold,
          size: 13.5,
        ),
      ),
    );
  }
}
