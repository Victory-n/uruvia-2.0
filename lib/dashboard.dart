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

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final firstName = user?.userMetadata?['first_name'] ?? 'User';
    final userInitials = firstName.isNotEmpty
        ? firstName[0].toUpperCase()
        : 'U';

    // Mock static dashboard values to match other redesigned lists
    const double revenueVal = 850000.0;
    const double expenseVal = 87200.0;
    const double profitVal = revenueVal - expenseVal;

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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: googleSansText(
                          text: "Cloud sync complete!",
                          colors: Colors.white,
                          fontWeight: FontWeight.normal,
                          size: 14.0,
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 1),
                      ),
                    );
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

                // 2. Overview Metrics Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
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
                        iconColor: ConstantColor.blueBackground,
                        iconBg: const Color(0xFFEFF6FF),
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
