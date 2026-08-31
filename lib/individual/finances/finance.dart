import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/individual/finances/reports/financial_reports.dart';
import 'package:uruvia/individual/finances/transaction.dart';
import 'package:uruvia/services/currency_service.dart';
import '../sidebar/individual_sidebar.dart';
import '../../shared/features/budgeting/budgeting_screen.dart';
import '../../shared/features/calculator/savings_calculator_screen.dart';
import '../../shared/widgets/custom_text.dart';

class IndividualFinancePage extends StatefulWidget {
  const IndividualFinancePage({super.key});

  @override
  State<IndividualFinancePage> createState() => _IndividualFinancePageState();
}

typedef FinancePage = IndividualFinancePage;

class _IndividualFinancePageState extends State<IndividualFinancePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColor.lightBackground,
      drawer: const IndividualSidebar(
        currentRoute: IndividualSidebarRoute.finances,
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: true,
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
          text: "Finance Dashboard",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 18.0,
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
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
                      googleSansText(
                        text: "Personal Account Balance",
                        colors: ConstantColor.paragraphTextSecondary,
                        fontWeight: FontWeight.w600,
                        size: 13.0,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: googleSansText(
                          text: "Active",
                          colors: Colors.green,
                          fontWeight: FontWeight.bold,
                          size: 11.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  ValueListenableBuilder<String>(
                    valueListenable: CurrencyService.instance.activeCurrencyNotifier,
                    builder: (context, activeCurrency, _) {
                      return googleSansText(
                        text: CurrencyService.format(250000.00, currency: activeCurrency),
                        colors: ConstantColor.headingTextPrimary,
                        fontWeight: FontWeight.bold,
                        size: 28.0,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Modules / Features Shortcuts
            googleSansText(
              text: "Finance Modules",
              colors: ConstantColor.headingTextPrimary,
              fontWeight: FontWeight.bold,
              size: 16.0,
            ),
            const SizedBox(height: 12.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.0),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: ConstantColor.blueBackground.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        color: ConstantColor.blueBackground,
                      ),
                    ),
                    title: googleSansText(
                      text: "Transactions",
                      colors: ConstantColor.headingTextPrimary,
                      fontWeight: FontWeight.bold,
                      size: 15.0,
                    ),
                    subtitle: googleSansText(
                      text: "View and manage all income & expense logs",
                      colors: ConstantColor.paragraphTextSecondary,
                      fontWeight: FontWeight.normal,
                      size: 12.0,
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const IndividualTransactionPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1.0),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Icon(
                        Icons.calculate_outlined,
                        color: Colors.purple,
                      ),
                    ),
                    title: googleSansText(
                      text: "Savings & Expense Calculator",
                      colors: ConstantColor.headingTextPrimary,
                      fontWeight: FontWeight.bold,
                      size: 15.0,
                    ),
                    subtitle: googleSansText(
                      text: "Calculate daily/weekly target rates & feasibility",
                      colors: ConstantColor.paragraphTextSecondary,
                      fontWeight: FontWeight.normal,
                      size: 12.0,
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SavingsCalculatorScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1.0),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Icon(
                        Icons.pie_chart_outline_rounded,
                        color: Colors.teal,
                      ),
                    ),
                    title: googleSansText(
                      text: "Budgeting",
                      colors: ConstantColor.headingTextPrimary,
                      fontWeight: FontWeight.bold,
                      size: 15.0,
                    ),
                    subtitle: googleSansText(
                      text: "Create and track monthly budget limits & targets",
                      colors: ConstantColor.paragraphTextSecondary,
                      fontWeight: FontWeight.normal,
                      size: 12.0,
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BudgetingScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1.0),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Icon(
                        Icons.bar_chart_rounded,
                        color: Colors.orange,
                      ),
                    ),
                    title: googleSansText(
                      text: "Financial Reports",
                      colors: ConstantColor.headingTextPrimary,
                      fontWeight: FontWeight.bold,
                      size: 15.0,
                    ),
                    subtitle: googleSansText(
                      text: "View financial analytics, cash flow & expense breakdown",
                      colors: ConstantColor.paragraphTextSecondary,
                      fontWeight: FontWeight.normal,
                      size: 12.0,
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FinancialReportsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Recent Transactions Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                googleSansText(
                  text: "Recent Activity",
                  colors: ConstantColor.headingTextPrimary,
                  fontWeight: FontWeight.bold,
                  size: 16.0,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const IndividualTransactionPage(),
                      ),
                    );
                  },
                  child: googleSansText(
                    text: "View All",
                    colors: ConstantColor.blueBackground,
                    fontWeight: FontWeight.bold,
                    size: 13.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),

            // Sample Recent Item Preview
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.0),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_downward_rounded,
                      color: Colors.green,
                      size: 20.0,
                    ),
                  ),
                  const SizedBox(width: 14.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        googleSansText(
                          text: "Salary Deposit",
                          colors: ConstantColor.headingTextPrimary,
                          fontWeight: FontWeight.bold,
                          size: 14.5,
                        ),
                        const SizedBox(height: 3.0),
                        googleSansText(
                          text: "Income • Today, 10:30 AM",
                          colors: ConstantColor.paragraphTextSecondary,
                          fontWeight: FontWeight.normal,
                          size: 12.0,
                        ),
                      ],
                    ),
                  ),
                  googleSansText(
                    text: "+₦350,000.00",
                    colors: Colors.green,
                    fontWeight: FontWeight.bold,
                    size: 14.5,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
