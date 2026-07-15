import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/screens/invoices/model/invoice_model.dart'; // For formatCurrency and formatDate
import 'package:uruvia/widgets/custom_text.dart';
import 'add_expense_page.dart';

class ExpenseListPage extends StatefulWidget {
  const ExpenseListPage({super.key});

  @override
  State<ExpenseListPage> createState() => _ExpenseListPageState();
}

class MockExpense {
  final String vendor;
  final String category;
  final DateTime date;
  final double amount;
  final String status; // 'Approved', 'Pending', 'Rejected'
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const MockExpense({
    required this.vendor,
    required this.category,
    required this.date,
    required this.amount,
    required this.status,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });
}

class _ExpenseListPageState extends State<ExpenseListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Dynamic lists of mock expenses
  final List<MockExpense> _allExpenses = [
    MockExpense(
      vendor: "Amazon Web Services",
      category: "Software & Hosting",
      date: DateTime.now().subtract(const Duration(days: 1)),
      amount: 42500.0,
      status: "Approved",
      icon: CupertinoIcons.cloud_fill,
      iconColor: const Color(0xFF0288D1),
      iconBgColor: const Color(0xFFE1F5FE),
    ),
    MockExpense(
      vendor: "Uber Technologies",
      category: "Transport",
      date: DateTime.now().subtract(const Duration(days: 2)),
      amount: 6800.0,
      status: "Approved",
      icon: CupertinoIcons.car_detailed,
      iconColor: const Color(0xFF3F51B5),
      iconBgColor: const Color(0xFFE8EAF6),
    ),
    MockExpense(
      vendor: "Starbucks Coffee",
      category: "Meals & Entertainment",
      date: DateTime.now().subtract(const Duration(days: 3)),
      amount: 4500.0,
      status: "Pending",
      icon: Icons.local_cafe_outlined,
      iconColor: const Color(0xFF2E7D32),
      iconBgColor: const Color(0xFFE8F5E9),
    ),
    MockExpense(
      vendor: "Office Depot",
      category: "Office Supplies",
      date: DateTime.now().subtract(const Duration(days: 5)),
      amount: 18200.0,
      status: "Approved",
      icon: CupertinoIcons.folder_badge_plus,
      iconColor: const Color(0xFFE65100),
      iconBgColor: const Color(0xFFFFE0B2),
    ),
    MockExpense(
      vendor: "Figma Design",
      category: "Software & Hosting",
      date: DateTime.now().subtract(const Duration(days: 8)),
      amount: 15000.0,
      status: "Rejected",
      icon: CupertinoIcons.pen,
      iconColor: const Color(0xFFC2185B),
      iconBgColor: const Color(0xFFFCE4EC),
    ),
  ];

  List<MockExpense> _filteredExpenses = [];

  @override
  void initState() {
    super.initState();
    _filteredExpenses = List.from(_allExpenses);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterExpenses(String query) {
    setState(() {
      _searchQuery = query.toLowerCase().trim();
      if (_searchQuery.isEmpty) {
        _filteredExpenses = List.from(_allExpenses);
      } else {
        _filteredExpenses = _allExpenses.where((exp) {
          return exp.vendor.toLowerCase().contains(_searchQuery) ||
              exp.category.toLowerCase().contains(_searchQuery);
        }).toList();
      }
    });
  }

  // Get total sum of expenses
  double get totalExpenses =>
      _allExpenses.fold(0.0, (sum, exp) => sum + exp.amount);
  double get budgetLimit => 250000.0;
  double get remainingBudget => budgetLimit - totalExpenses;

  // Status themes
  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF2E7D32);
      case 'pending':
        return const Color(0xFFE65100);
      case 'rejected':
        return const Color(0xFFC62828);
      default:
        return ConstantColor.paragraphTextSecondary;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFFE8F5E9);
      case 'pending':
        return const Color(0xFFFFF3E0);
      case 'rejected':
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFECEFF1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        backgroundColor: const Color(0xFFF9FAFC),
        leading: IconButton(
          icon: const Icon(
            CupertinoIcons.bars,
            color: ConstantColor.headingTextPrimary,
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: googleSansText(
          text: "Expenses",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 22.0,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: googleSansText(
                    text: "Connecting to Cloud storage...",
                    colors: Colors.white,
                    fontWeight: FontWeight.normal,
                    size: 14.0,
                  ),
                  backgroundColor: ConstantColor.blueBackground,
                ),
              );
            },
            icon: Platform.isAndroid
                ? const Icon(
                    Icons.cloud_done_outlined,
                    color: ConstantColor.blueBackground,
                  )
                : const Icon(
                    CupertinoIcons.cloud_upload,
                    color: ConstantColor.blueBackground,
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            slideRightWidget(newPage: const AddExpensePage(), context: context),
        backgroundColor: ConstantColor.blueBackground,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
        ),
        icon: const Icon(CupertinoIcons.add, color: Colors.white, size: 20.0),
        label: googleSansText(
          text: "Add Expense",
          colors: Colors.white,
          fontWeight: FontWeight.bold,
          size: 14.0,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8.0),

              // 1. Overview Metrics Cards Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.015),
                            blurRadius: 10.0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          googleSansText(
                            text: "Total Expenses",
                            colors: ConstantColor.paragraphTextSecondary,
                            fontWeight: FontWeight.bold,
                            size: 10.0,
                          ),
                          const SizedBox(height: 4.0),
                          googleSansText(
                            text: "₦${formatCurrency(totalExpenses)}",
                            colors: ConstantColor.headingTextPrimary,
                            fontWeight: FontWeight.w900,
                            size: 16.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.015),
                            blurRadius: 10.0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          googleSansText(
                            text: "Remaining Budget",
                            colors: ConstantColor.paragraphTextSecondary,
                            fontWeight: FontWeight.bold,
                            size: 10.0,
                          ),
                          const SizedBox(height: 4.0),
                          googleSansText(
                            text: "₦${formatCurrency(remainingBudget)}",
                            colors: remainingBudget < 50000
                                ? Colors.redAccent
                                : Colors.green,
                            fontWeight: FontWeight.w900,
                            size: 16.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // 2. Custom Styled Search Bar & Filter
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.01),
                            blurRadius: 8.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterExpenses,
                        decoration: InputDecoration(
                          hintText: "Search vendor or category",
                          hintStyle: TextStyle(
                            fontFamily: "googleSans",
                            color: ConstantColor.paragraphTextSecondary
                                .withOpacity(0.6),
                            fontSize: 14.0,
                          ),
                          prefixIcon: Icon(
                            CupertinoIcons.search,
                            color: ConstantColor.paragraphTextSecondary
                                .withOpacity(0.6),
                            size: 18.0,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: "googleSans",
                          fontSize: 14.0,
                          color: ConstantColor.headingTextPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  // Sort Icon Button Container
                  Container(
                    height: 48.0,
                    width: 48.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: IconButton(
                      onPressed: () {
                        // Reverse current list sort order
                        setState(() {
                          _filteredExpenses = _filteredExpenses.reversed
                              .toList();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: googleSansText(
                              text: "Sorted expenses list",
                              colors: Colors.white,
                              fontWeight: FontWeight.normal,
                              size: 14.0,
                            ),
                            backgroundColor: Colors.black87,
                            duration: const Duration(milliseconds: 800),
                          ),
                        );
                      },
                      icon: const Icon(
                        CupertinoIcons.sort_down,
                        size: 20.0,
                        color: ConstantColor.paragraphTextPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // 3. Scrollable List view
              Expanded(
                child: _filteredExpenses.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/img/capital.png",
                                color: ConstantColor.paragraphTextSecondary
                                    .withOpacity(0.4),
                                height: 56.0,
                                width: 56.0,
                              ),
                              const SizedBox(height: 14.0),
                              googleSansText(
                                text: "No matching expense entries found.",
                                colors: ConstantColor.paragraphTextSecondary,
                                fontWeight: FontWeight.normal,
                                size: 15.0,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _filteredExpenses.length,
                        itemBuilder: (context, idx) {
                          final item = _filteredExpenses[idx];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12.0),
                            padding: const EdgeInsets.all(14.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                color: const Color(0xFFEEEEEE),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.015),
                                  blurRadius: 8.0,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Category Icon avatar
                                CircleAvatar(
                                  radius: 20.0,
                                  backgroundColor: item.iconBgColor,
                                  child: Icon(
                                    item.icon,
                                    color: item.iconColor,
                                    size: 18.0,
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                // Vendor & details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      googleSansText(
                                        text: item.vendor,
                                        colors:
                                            ConstantColor.headingTextPrimary,
                                        fontWeight: FontWeight.bold,
                                        size: 15.0,
                                      ),
                                      const SizedBox(height: 2.0),
                                      Row(
                                        children: [
                                          googleSansText(
                                            text: item.category,
                                            colors: ConstantColor
                                                .paragraphTextSecondary,
                                            fontWeight: FontWeight.bold,
                                            size: 10.5,
                                          ),
                                          const SizedBox(width: 6.0),
                                          Container(
                                            width: 3,
                                            height: 3,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFFBBBBBB),
                                            ),
                                          ),
                                          const SizedBox(width: 6.0),
                                          googleSansText(
                                            text: formatDate(item.date),
                                            colors: ConstantColor
                                                .paragraphTextSecondary,
                                            fontWeight: FontWeight.normal,
                                            size: 10.5,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                // Amount & Status
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    googleSansText(
                                      text: "₦${formatCurrency(item.amount)}",
                                      colors: ConstantColor.headingTextPrimary,
                                      fontWeight: FontWeight.w900,
                                      size: 15.0,
                                    ),
                                    const SizedBox(height: 3.0),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 3.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusBgColor(item.status),
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                      child: googleSansText(
                                        text: item.status,
                                        colors: _getStatusTextColor(
                                          item.status,
                                        ),
                                        fontWeight: FontWeight.bold,
                                        size: 10.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
