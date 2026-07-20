import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/screens/invoices/model/invoice_model.dart'; // For formatCurrency and formatDate
import 'package:uruvia/widgets/custom_text.dart';
import 'package:uruvia/classes/custom_snackbar.dart';
import 'add_expense_page.dart';
import 'sales/sales_model.dart';
import 'sales/sales_repository.dart';
import 'package:uruvia/offline/database_helper.dart';

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

class _ExpenseListPageState extends State<ExpenseListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Expenses data
  List<MockExpense> _allExpenses = [];
  List<MockExpense> _filteredExpenses = [];

  // Sales data
  List<Sale> _allSales = [];
  List<Sale> _filteredSales = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadExpensesAndSalesData();
  }

  Future<void> _loadExpensesAndSalesData() async {
    final fetchedSales = await SalesRepository.instance.getSales();
    final dbHelper = DatabaseHelper.instance;
    final cachedExpenses = await dbHelper.queryCache('local_expenses');

    final List<MockExpense> loadedExpenses = cachedExpenses.map((row) {
      final vendor = row['vendor'] as String? ?? (row['category'] as String? ?? 'Expense Item');
      final category = row['category'] as String? ?? 'General Expense';
      final amount = (row['amount'] as num? ?? 0.0).toDouble();
      final status = row['status'] as String? ?? 'Approved';
      final date = row['created_at'] != null
          ? DateTime.tryParse(row['created_at'].toString()) ?? DateTime.now()
          : DateTime.now();

      return MockExpense(
        vendor: vendor,
        category: category,
        date: date,
        amount: amount,
        status: status,
        icon: CupertinoIcons.money_dollar_circle_fill,
        iconColor: ConstantColor.blueBackground,
        iconBgColor: ConstantColor.blueBackground.withAlpha(25),
      );
    }).toList();

    if (mounted) {
      setState(() {
        _allSales = fetchedSales;
        _filteredSales = List.from(_allSales);
        _allExpenses = loadedExpenses;
        _filteredExpenses = List.from(_allExpenses);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterData(String query) {
    setState(() {
      _searchQuery = query.toLowerCase().trim();
      if (_searchQuery.isEmpty) {
        _filteredExpenses = List.from(_allExpenses);
        _filteredSales = List.from(_allSales);
      } else {
        _filteredExpenses = _allExpenses.where((exp) {
          return exp.vendor.toLowerCase().contains(_searchQuery) ||
              exp.category.toLowerCase().contains(_searchQuery);
        }).toList();

        _filteredSales = _allSales.where((sale) {
          return sale.customerName.toLowerCase().contains(_searchQuery) ||
              sale.invoiceNumber.toLowerCase().contains(_searchQuery);
        }).toList();
      }
    });
  }

  // Get total sum of expenses
  double get totalExpenses =>
      _allExpenses.fold(0.0, (sum, exp) => sum + exp.amount);

  // Get total sum of sales
  double get totalSales => _allSales.fold(0.0, (sum, sale) => sum + sale.amount);

  double get budgetLimit => 250000.0;
  // Remaining budget reflects sales revenue inflow
  double get remainingBudget => (budgetLimit + totalSales) - totalExpenses;

  // Status themes
  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'paid':
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
      case 'paid':
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
        leading: Navigator.canPop(context)
            ? null
            : IconButton(
                icon: const Icon(
                  CupertinoIcons.bars,
                  color: ConstantColor.headingTextPrimary,
                ),
                onPressed: () => Scaffold.maybeOf(context)?.openDrawer(),
              ),
        title: googleSansText(
          text: "Expense & Sales",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 22.0,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await _loadExpensesAndSalesData();
              if (context.mounted) {
                CustomSnackbar.showNormal(
                  context,
                  "Refreshed Expenses & Sales data",
                );
              }
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: ConstantColor.blueBackground,
          unselectedLabelColor: ConstantColor.paragraphTextSecondary,
          indicatorColor: ConstantColor.blueBackground,
          indicatorWeight: 3.0,
          labelStyle: const TextStyle(
            fontFamily: "googleSans",
            fontWeight: FontWeight.bold,
            fontSize: 15.0,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: "googleSans",
            fontWeight: FontWeight.w500,
            fontSize: 15.0,
          ),
          tabs: const [
            Tab(text: "Expenses"),
            Tab(text: "Sales"),
          ],
        ),
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
              const SizedBox(height: 12.0),

              // 1. Overview Metrics Cards Row reflecting Sales & Remaining Budget
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.0),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.015),
                            blurRadius: 8.0,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          googleSansText(
                            text: "Total Sales",
                            colors: const Color(0xFF2E7D32),
                            fontWeight: FontWeight.bold,
                            size: 10.0,
                          ),
                          const SizedBox(height: 4.0),
                          googleSansText(
                            text: "₦${formatCurrency(totalSales)}",
                            colors: ConstantColor.headingTextPrimary,
                            fontWeight: FontWeight.w900,
                            size: 14.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.0),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.015),
                            blurRadius: 8.0,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          googleSansText(
                            text: "Total Expenses",
                            colors: const Color(0xFFC62828),
                            fontWeight: FontWeight.bold,
                            size: 10.0,
                          ),
                          const SizedBox(height: 4.0),
                          googleSansText(
                            text: "₦${formatCurrency(totalExpenses)}",
                            colors: ConstantColor.headingTextPrimary,
                            fontWeight: FontWeight.w900,
                            size: 14.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.0),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.015),
                            blurRadius: 8.0,
                            offset: const Offset(0, 3),
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
                                : ConstantColor.blueBackground,
                            fontWeight: FontWeight.w900,
                            size: 14.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14.0),

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
                        onChanged: _filterData,
                        decoration: InputDecoration(
                          hintText: "Search entry...",
                          hintStyle: TextStyle(
                            fontFamily: "googleSans",
                            color: ConstantColor.paragraphTextSecondary
                                .withOpacity(0.6),
                            fontSize: 13.5,
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
                        setState(() {
                          _filteredExpenses =
                              _filteredExpenses.reversed.toList();
                          _filteredSales = _filteredSales.reversed.toList();
                        });
                        CustomSnackbar.showNormal(context, "Sorted list order");
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
              const SizedBox(height: 14.0),

              // 3. TabView Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Expenses List
                    _buildExpensesTab(),
                    // Tab 2: Sales List (Paid Invoices)
                    _buildSalesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpensesTab() {
    if (_filteredExpenses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/img/capital.png",
                color: ConstantColor.paragraphTextSecondary.withOpacity(0.4),
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
      );
    }

    return ListView.builder(
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
            border: Border.all(color: const Color(0xFFEEEEEE)),
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
              CircleAvatar(
                radius: 20.0,
                backgroundColor: item.iconBgColor,
                child: Icon(item.icon, color: item.iconColor, size: 18.0),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    googleSansText(
                      text: item.vendor,
                      colors: ConstantColor.headingTextPrimary,
                      fontWeight: FontWeight.bold,
                      size: 15.0,
                    ),
                    const SizedBox(height: 2.0),
                    Row(
                      children: [
                        googleSansText(
                          text: item.category,
                          colors: ConstantColor.paragraphTextSecondary,
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
                          colors: ConstantColor.paragraphTextSecondary,
                          fontWeight: FontWeight.normal,
                          size: 10.5,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
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
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: googleSansText(
                      text: item.status,
                      colors: _getStatusTextColor(item.status),
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
    );
  }

  Widget _buildSalesTab() {
    if (_filteredSales.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.arrow_down_right_circle_fill,
                color: Color(0xFF2E7D32),
                size: 56.0,
              ),
              const SizedBox(height: 14.0),
              googleSansText(
                text: "No sales records found.",
                colors: ConstantColor.headingTextPrimary,
                fontWeight: FontWeight.bold,
                size: 16.0,
              ),
              const SizedBox(height: 4.0),
              googleSansText(
                text:
                    "Sales are automatically logged here whenever an invoice is marked as paid.",
                colors: ConstantColor.paragraphTextSecondary,
                fontWeight: FontWeight.normal,
                size: 13.0,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: _filteredSales.length,
      itemBuilder: (context, idx) {
        final sale = _filteredSales[idx];
        return Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0xFFEEEEEE)),
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
              const CircleAvatar(
                radius: 20.0,
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(
                  CupertinoIcons.arrow_down_right,
                  color: Color(0xFF2E7D32),
                  size: 18.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    googleSansText(
                      text: sale.customerName,
                      colors: ConstantColor.headingTextPrimary,
                      fontWeight: FontWeight.bold,
                      size: 15.0,
                    ),
                    const SizedBox(height: 2.0),
                    Row(
                      children: [
                        googleSansText(
                          text: sale.invoiceNumber,
                          colors: ConstantColor.blueBackground,
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
                          text: formatDate(sale.datePaid),
                          colors: ConstantColor.paragraphTextSecondary,
                          fontWeight: FontWeight.normal,
                          size: 10.5,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  googleSansText(
                    text: "+₦${formatCurrency(sale.amount)}",
                    colors: const Color(0xFF2E7D32),
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
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: googleSansText(
                      text: sale.status,
                      colors: const Color(0xFF2E7D32),
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
    );
  }
}
