import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uruvia/offline/connectivity_service.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/screens/business%20health/business_health.dart';
import 'package:uruvia/screens/expenses/expense_list_page.dart';
import 'package:uruvia/screens/expenses/add_expense_page.dart';
import 'package:uruvia/screens/invoices/add_invoice_page.dart';
import 'package:uruvia/screens/invoices/model/invoice_model.dart'; // For formatCurrency
import 'package:uruvia/screens/inventory/inventory_main_page.dart';
import 'package:uruvia/widgets/custom_column_heading_text.dart';
import 'package:uruvia/widgets/custom_text.dart';
import 'package:uruvia/screens/tasks/task_model.dart';
import 'package:uruvia/screens/tasks/tasks_repository.dart';
import 'package:uruvia/screens/tasks/tasks_main_page.dart';

import 'package:flutter/foundation.dart';
import 'package:uruvia/offline/database_helper.dart';
import 'package:uruvia/classes/custom_snackbar.dart';

class DashboardInvoice {
  final String id;
  final double amount;
  final String status; // 'Paid', 'Sent', 'Overdue', 'Draft'
  final DateTime date;

  DashboardInvoice({
    required this.id,
    required this.amount,
    required this.status,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'amount': amount,
        'status': status,
        'created_at': date.toIso8601String(),
      };
}

class DashboardExpense {
  final String id;
  final double amount;
  final String status; // 'Approved', 'Pending', 'Rejected'
  final DateTime date;

  DashboardExpense({
    required this.id,
    required this.amount,
    required this.status,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'amount': amount,
        'status': status,
        'created_at': date.toIso8601String(),
      };
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String _selectedPeriod = 'This Month';

  final List<String> _periods = [
    'This Month',
    'This Quarter',
    'This Year',
    'All Time',
  ];

  List<DashboardInvoice> _invoices = [];
  List<DashboardExpense> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadDatabaseData();
  }

  Future<void> _loadDatabaseData() async {
    try {
      // 1. Query SQLite local cache
      final dbHelper = DatabaseHelper.instance;
      final cachedInvoices = await dbHelper.queryCache('local_invoices');
      final cachedExpenses = await dbHelper.queryCache('local_expenses');

      if (mounted && cachedInvoices.isNotEmpty) {
        final List<DashboardInvoice> localInvoices = cachedInvoices.map((row) {
          return DashboardInvoice(
            id: row['id'] as String,
            amount: (row['amount'] as num).toDouble(),
            status: row['status'] as String,
            date: DateTime.parse(row['created_at'] as String),
          );
        }).toList();
        setState(() {
          _invoices = localInvoices;
        });
      }

      if (mounted && cachedExpenses.isNotEmpty) {
        final List<DashboardExpense> localExpenses = cachedExpenses.map((row) {
          return DashboardExpense(
            id: row['id'] as String,
            amount: (row['amount'] as num).toDouble(),
            status: row['status'] as String,
            date: DateTime.parse(row['created_at'] as String),
          );
        }).toList();
        setState(() {
          _expenses = localExpenses;
        });
      }

      // 2. Fetch live data from Supabase database
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final invoicesData = await Supabase.instance.client
            .from('invoices')
            .select()
            .eq('user_id', user.id);

        final expensesData = await Supabase.instance.client
            .from('expenses')
            .select()
            .eq('user_id', user.id);

        final List<DashboardInvoice> remoteInvoices = [];
        for (var row in (invoicesData as List)) {
          final inv = DashboardInvoice(
            id: row['id']?.toString() ?? '',
            amount: ((row['amount'] ?? row['total']) ?? 0.0).toDouble(),
            status: row['status'] ?? 'Paid',
            date: row['created_at'] != null
                ? DateTime.parse(row['created_at'])
                : (row['invoice_date'] != null
                    ? DateTime.parse(row['invoice_date'])
                    : DateTime.now()),
          );
          remoteInvoices.add(inv);
          await dbHelper.cacheUpsert('local_invoices', inv.toMap());
        }

        final List<DashboardExpense> remoteExpenses = [];
        for (var row in (expensesData as List)) {
          final exp = DashboardExpense(
            id: row['id']?.toString() ?? '',
            amount: (row['amount'] ?? 0.0).toDouble(),
            status: row['status'] ?? 'Approved',
            date: row['created_at'] != null
                ? DateTime.parse(row['created_at'])
                : (row['date'] != null
                    ? DateTime.parse(row['date'])
                    : DateTime.now()),
          );
          remoteExpenses.add(exp);
          await dbHelper.cacheUpsert('local_expenses', exp.toMap());
        }

        if (mounted && (remoteInvoices.isNotEmpty || remoteExpenses.isNotEmpty)) {
          setState(() {
            if (remoteInvoices.isNotEmpty) _invoices = remoteInvoices;
            if (remoteExpenses.isNotEmpty) _expenses = remoteExpenses;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Database sync info / fallback to cache: $e");
      }
    }
  }

  bool _isDateInPeriod(DateTime date, String period) {
    final now = DateTime.now();
    switch (period) {
      case 'This Month':
        return date.year == now.year && date.month == now.month;
      case 'This Quarter':
        final currentQuarter = ((now.month - 1) ~/ 3) + 1;
        final dateQuarter = ((date.month - 1) ~/ 3) + 1;
        return date.year == now.year && dateQuarter == currentQuarter;
      case 'This Year':
        return date.year == now.year;
      case 'All Time':
      default:
        return true;
    }
  }

  double get _totalRevenue {
    return _invoices
        .where((inv) =>
            inv.status == 'Paid' && _isDateInPeriod(inv.date, _selectedPeriod))
        .fold(0.0, (sum, inv) => sum + inv.amount);
  }

  double get _totalExpense {
    return _expenses
        .where((exp) =>
            exp.status == 'Approved' &&
            _isDateInPeriod(exp.date, _selectedPeriod))
        .fold(0.0, (sum, exp) => sum + exp.amount);
  }

  double get _netProfit => _totalRevenue - _totalExpense;

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final firstName = user?.userMetadata?['first_name'] ?? 'User';
    final userInitials = firstName.isNotEmpty
        ? firstName[0].toUpperCase()
        : 'U';

    final revenueVal = _totalRevenue;
    final expenseVal = _totalExpense;
    final profitVal = _netProfit;

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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => Scaffold.maybeOf(context)?.openDrawer(),
              child: CircleAvatar(
                radius: 15,
                backgroundColor: const Color(0xFFEFF6FF),
                child: googleSansText(
                  text: userInitials,
                  colors: ConstantColor.blueBackground,
                  fontWeight: FontWeight.bold,
                  size: 13.0,
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            googleSansText(
              text: "Uruvia",
              colors: ConstantColor.headingTextPrimary,
              fontWeight: FontWeight.bold,
              size: 18.0,
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: ConnectivityService.instance.isConnected,
            builder: (context, isOnline, _) {
              if (isOnline) {
                return IconButton(
                  onPressed: () {
                    CustomSnackbar.showSuccess(context, "Cloud sync complete!");
                  },
                  icon: Icon(
                    Platform.isAndroid
                        ? Icons.cloud_done_outlined
                        : CupertinoIcons.cloud_upload,
                    color: ConstantColor.blueBackground,
                  ),
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.cloud_off,
                        color: Colors.redAccent,
                        size: 20.0,
                      ),
                      SizedBox(width: 4.0),
                      Text(
                        "Offline",
                        style: TextStyle(
                          fontFamily: "Inter",
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.0,
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Welcome Card Banner
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      interText(
                        text: "Welcome, $firstName",
                        colors: ConstantColor.headingTextPrimary,
                        fontWeight: FontWeight.bold,
                        size: 24.0,
                      ),
                      const SizedBox(height: 4.0),
                      googleSansText(
                        text: "Your business command centre is ready.",
                        colors: ConstantColor.paragraphTextSecondary,
                        fontWeight: FontWeight.normal,
                        size: 14.0,
                      ),
                    ],
                  ),
                ),

                // 2. Overview Metrics Grid with Period Filter Toggle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Period Filter Toggle Bar
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: _periods.map((period) {
                            final isSelected = _selectedPeriod == period;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(period),
                                selected: isSelected,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedPeriod = period;
                                  });
                                },
                                selectedColor: const Color(0xFFEFF6FF),
                                backgroundColor: Colors.white,
                                showCheckmark: false,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                side: BorderSide(
                                  color: isSelected
                                      ? ConstantColor.blueBackground
                                      : const Color(0xFFE2E8F0),
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                                labelStyle: TextStyle(
                                  fontFamily: "Inter",
                                  fontSize: 12.5,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? ConstantColor.blueBackground
                                      : ConstantColor.paragraphTextSecondary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      Row(
                        children: [
                          // Total Revenue
                          Expanded(
                            child: _buildMetricCard(
                              title: "Total Revenue",
                              value: "₦${formatCurrency(revenueVal)}",
                              icon: CupertinoIcons.arrow_down_right_circle_fill,
                              iconColor: const Color(0xFF2E7D32),
                              iconBg: const Color(0xFFE8F5E9),
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          // Total Expense
                          Expanded(
                            child: _buildMetricCard(
                              title: "Total Expense",
                              value: "₦${formatCurrency(expenseVal)}",
                              icon: CupertinoIcons.arrow_up_right_circle_fill,
                              iconColor: const Color(0xFFC62828),
                              iconBg: const Color(0xFFFFEBEE),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      // Net Profit
                      _buildMetricCard(
                        title: "Net Profit",
                        value: "₦${formatCurrency(profitVal)}",
                        icon: CupertinoIcons.graph_circle_fill,
                        iconColor: profitVal >= 0
                            ? ConstantColor.blueBackground
                            : const Color(0xFFC62828),
                        iconBg: profitVal >= 0
                            ? const Color(0xFFEFF6FF)
                            : const Color(0xFFFFEBEE),
                        isFullWidth: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),

                // 2.5 Upcoming Tasks Widget
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: FutureBuilder<List<Task>>(
                    future: TasksRepository.instance.getTasks(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox.shrink();
                      }
                      final tasks = snapshot.data ?? [];
                      final pendingTasks = tasks
                          .where((t) => !t.isCompleted)
                          .take(3)
                          .toList();
                      if (pendingTasks.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 24.0),
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          color: Colors.white,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      CupertinoIcons.list_bullet,
                                      color: ConstantColor.headingTextPrimary,
                                      size: 18.0,
                                    ),
                                    const SizedBox(width: 8.0),
                                    interText(
                                      text: "Upcoming Tasks",
                                      colors: ConstantColor.headingTextPrimary,
                                      fontWeight: FontWeight.bold,
                                      size: 16.0,
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    slideRightWidget(
                                      newPage: const TasksMainPage(),
                                      context: context,
                                    );
                                  },
                                  child: googleSansText(
                                    text: "See All",
                                    colors: ConstantColor.blueBackground,
                                    fontWeight: FontWeight.bold,
                                    size: 13.0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14.0),
                            ...pendingTasks.map((task) {
                              final taskColor = task.type == 'inventory'
                                  ? const Color(0xFFE65100)
                                  : task.type == 'expense'
                                  ? const Color(0xFFC62828)
                                  : task.type == 'invoice'
                                  ? ConstantColor.blueBackground
                                  : const Color(0xFF546E7A);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8.0,
                                      height: 8.0,
                                      decoration: BoxDecoration(
                                        color: taskColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 10.0),
                                    Expanded(
                                      child: googleSansText(
                                        text: task.title,
                                        colors:
                                            ConstantColor.headingTextPrimary,
                                        fontWeight: FontWeight.w600,
                                        size: 14.0,
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    googleSansText(
                                      text: formatDate(task.dueDate),
                                      colors:
                                          ConstantColor.paragraphTextSecondary,
                                      fontWeight: FontWeight.normal,
                                      size: 12.0,
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // 3. "Get Down to Business" Card
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: Colors.white,
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/img/rocket.png",
                        height: 72.0,
                        width: 72.0,
                      ),
                      const SizedBox(height: 16.0),
                      columnText(
                        headingText: interText(
                          text: "Let's get down to business",
                          colors: ConstantColor.headingTextPrimary,
                          fontWeight: FontWeight.bold,
                          size: 20.0,
                          textAlign: TextAlign.center,
                        ),
                        subtext: googleSansText(
                          text:
                              "Start by adding your first invoice, expense, or product to see your business health and insights here.",
                          colors: ConstantColor.paragraphTextSecondary,
                          fontWeight: FontWeight.normal,
                          size: 13.5,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => slideUpWidget(
                              newPage: const AddInvoicePage(),
                              context: context,
                            ),
                            icon: const Icon(
                              CupertinoIcons.add,
                              color: Colors.white,
                              size: 16.0,
                            ),
                            label: interText(
                              text: "Create Invoice",
                              colors: Colors.white,
                              fontWeight: FontWeight.bold,
                              size: 14.0,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ConstantColor.blueBackground,
                              elevation: 0.0,
                              minimumSize: const Size(double.infinity, 44.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => slideRightWidget(
                                    newPage: const AddExpensePage(),
                                    context: context,
                                  ),
                                  icon: const Icon(
                                    CupertinoIcons.doc_text,
                                    color: ConstantColor.headingTextPrimary,
                                    size: 16.0,
                                  ),
                                  label: interText(
                                    text: "Log Expense",
                                    colors: ConstantColor.headingTextPrimary,
                                    fontWeight: FontWeight.bold,
                                    size: 14.0,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xFFCCCCCC),
                                    ),
                                    minimumSize: const Size(0, 44.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => slideUpWidget(
                                    newPage: const AddInvoicePage(),
                                    context: context,
                                  ),
                                  icon: const Icon(
                                    CupertinoIcons.tag,
                                    color: ConstantColor.headingTextPrimary,
                                    size: 16.0,
                                  ),
                                  label: interText(
                                    text: "Record Sales",
                                    colors: ConstantColor.headingTextPrimary,
                                    fontWeight: FontWeight.bold,
                                    size: 14.0,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xFFCCCCCC),
                                    ),
                                    minimumSize: const Size(0, 44.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),

                // 4. Business Health Score
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: Colors.white,
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
                      Row(
                        children: [
                          const Icon(
                            CupertinoIcons.shield,
                            color: ConstantColor.headingTextPrimary,
                            size: 18.0,
                          ),
                          const SizedBox(width: 8.0),
                          interText(
                            text: "Business Health Score",
                            colors: ConstantColor.headingTextPrimary,
                            fontWeight: FontWeight.bold,
                            size: 16.0,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14.0),
                      GestureDetector(
                        onTap: () => slideRightWidget(
                          newPage: const BusinessHealthPage(),
                          context: context,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 24.0,
                            horizontal: 16.0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            color: const Color(0xFFF8FAFC),
                          ),
                          child: Column(
                            children: [
                              SvgPicture.asset(
                                "assets/svg/graph_search.svg",
                                height: 48.0,
                              ),
                              const SizedBox(height: 12.0),
                              interText(
                                text:
                                    "Score will calculate after your first few entries. Keep adding data to unlock insights.",
                                colors: ConstantColor.paragraphTextSecondary,
                                fontWeight: FontWeight.normal,
                                size: 13.0,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),

                // 5. Quick Start Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: interText(
                    text: "Quick Start",
                    colors: ConstantColor.headingTextPrimary,
                    fontWeight: FontWeight.bold,
                    size: 18.0,
                  ),
                ),
                const SizedBox(height: 10.0),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: Colors.white,
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
                    children: [
                      // Item 1: Invoice
                      _buildQuickStartRow(
                        onTap: () => slideUpWidget(
                          newPage: const AddInvoicePage(),
                          context: context,
                        ),
                        avatarBg: const Color(0xFFEFF6FF),
                        icon: CupertinoIcons.add,
                        iconColor: ConstantColor.blueBackground,
                        title: "Create your first invoice",
                        subtitle: "Bill a client for your services",
                      ),
                      const Divider(
                        color: Color(0xFFF1F5F9),
                        height: 1.0,
                        indent: 64.0,
                      ),
                      // Item 2: Expense
                      _buildQuickStartRow(
                        onTap: () => slideRightWidget(
                          newPage: const AddExpensePage(),
                          context: context,
                        ),
                        avatarBg: const Color(0xFFFFF3E0),
                        icon: CupertinoIcons.doc_text,
                        iconColor: const Color(0xFFE65100),
                        title: "Log a business expense",
                        subtitle: "Track your outgoing costs",
                      ),
                      const Divider(
                        color: Color(0xFFF1F5F9),
                        height: 1.0,
                        indent: 64.0,
                      ),
                      // Item 3: Inventory
                      _buildQuickStartRow(
                        onTap: () => slideRightWidget(
                          newPage: const InventoryMainPage(),
                          context: context,
                        ),
                        avatarBg: const Color(0xFFE8F5E9),
                        icon: CupertinoIcons.archivebox,
                        iconColor: const Color(0xFF2E7D32),
                        title: "Add a product to inventory",
                        subtitle: "Set up items you sell",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Dashboard Metrics Widget
  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
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
            backgroundColor: iconBg,
            child: Icon(icon, color: iconColor, size: 20.0),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                googleSansText(
                  text: title,
                  colors: ConstantColor.paragraphTextSecondary,
                  fontWeight: FontWeight.bold,
                  size: 11.5,
                ),
                const SizedBox(height: 4.0),
                googleSansText(
                  text: value,
                  colors: ConstantColor.headingTextPrimary,
                  fontWeight: FontWeight.w900,
                  size: isFullWidth ? 20.0 : 15.5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Quick Start List Item Widget
  Widget _buildQuickStartRow({
    required VoidCallback onTap,
    required Color avatarBg,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22.0,
              backgroundColor: avatarBg,
              child: Icon(icon, color: iconColor, size: 20.0),
            ),
            const SizedBox(width: 14.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  interText(
                    text: title,
                    colors: ConstantColor.headingTextPrimary,
                    fontWeight: FontWeight.bold,
                    size: 14.5,
                  ),
                  const SizedBox(height: 2.0),
                  googleSansText(
                    text: subtitle,
                    colors: ConstantColor.paragraphTextSecondary,
                    fontWeight: FontWeight.normal,
                    size: 12.5,
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: ConstantColor.paragraphTextSecondary,
              size: 14.0,
            ),
          ],
        ),
      ),
    );
  }
}
