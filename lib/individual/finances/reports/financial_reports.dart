import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import '../../../shared/widgets/custom_text.dart';

class FinancialReportsPage extends StatefulWidget {
  const FinancialReportsPage({super.key});

  @override
  State<FinancialReportsPage> createState() => _FinancialReportsPageState();
}

class _FinancialReportsPageState extends State<FinancialReportsPage> {
  String _selectedPeriod = 'This Week';

  final List<String> _periods = [
    'This Week',
    'This Month',
    'Last Month',
    'This Year',
  ];

  final List<Map<String, dynamic>> _categoryExpenses = const [
    {
      'category': 'Housing & Rent',
      'amount': '₦120,000.00',
      'percentage': 0.40,
      'color': Colors.blue,
      'icon': Icons.home_outlined,
    },
    {
      'category': 'Food & Dining',
      'amount': '₦65,000.00',
      'percentage': 0.22,
      'color': Colors.orange,
      'icon': Icons.restaurant_outlined,
    },
    {
      'category': 'Transportation',
      'amount': '₦45,000.00',
      'percentage': 0.15,
      'color': Colors.purple,
      'icon': Icons.directions_car_outlined,
    },
    {
      'category': 'Utilities & Bills',
      'amount': '₦35,000.00',
      'percentage': 0.12,
      'color': Colors.teal,
      'icon': Icons.bolt_outlined,
    },
    {
      'category': 'Entertainment',
      'amount': '₦30,000.00',
      'percentage': 0.11,
      'color': Colors.pinkAccent,
      'icon': Icons.movie_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColor.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: ConstantColor.headingTextPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: googleSansText(
          text: "Financial Reports",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 18.0,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.download_rounded,
              color: ConstantColor.blueBackground,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Exporting Financial Report (PDF)..."),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                googleSansText(
                  text: "Overview Summary",
                  colors: ConstantColor.headingTextPrimary,
                  fontWeight: FontWeight.bold,
                  size: 16.0,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPeriod,
                      icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ConstantColor.headingTextPrimary,
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedPeriod = newValue;
                          });
                        }
                      },
                      items: _periods.map((String period) {
                        return DropdownMenuItem<String>(
                          value: period,
                          child: Text(period),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Financial Summary Metric Grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: "Total Income",
                    value: "₦425,000.00",
                    trend: "+12.4%",
                    isPositive: true,
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: _buildMetricCard(
                    title: "Total Expenses",
                    value: "₦295,000.00",
                    trend: "-4.1%",
                    isPositive: true,
                    icon: Icons.trending_down,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: "Net Cashflow",
                    value: "₦130,000.00",
                    trend: "+18.2%",
                    isPositive: true,
                    icon: Icons.account_balance_wallet_outlined,
                    color: ConstantColor.blueBackground,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: _buildMetricCard(
                    title: "Savings Rate",
                    value: "30.5%",
                    trend: "+3.2%",
                    isPositive: true,
                    icon: Icons.savings_outlined,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24.0),

            // Expense Breakdown Section
            googleSansText(
              text: "Expense Breakdown by Category",
              colors: ConstantColor.headingTextPrimary,
              fontWeight: FontWeight.bold,
              size: 16.0,
            ),
            const SizedBox(height: 12.0),

            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: _categoryExpenses.map((cat) {
                  final Color catColor = cat['color'] as Color;
                  final double pct = cat['percentage'] as double;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                color: catColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Icon(
                                cat['icon'] as IconData,
                                color: catColor,
                                size: 18.0,
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: googleSansText(
                                text: cat['category'] as String,
                                colors: ConstantColor.headingTextPrimary,
                                fontWeight: FontWeight.w600,
                                size: 14.0,
                              ),
                            ),
                            googleSansText(
                              text: cat['amount'] as String,
                              colors: ConstantColor.headingTextPrimary,
                              fontWeight: FontWeight.bold,
                              size: 14.0,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6.0),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 6.0,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(catColor),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String trend,
    required bool isPositive,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(icon, color: color, size: 20.0),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6.0,
                  vertical: 2.0,
                ),
                decoration: BoxDecoration(
                  color: (isPositive ? Colors.green : Colors.red).withOpacity(
                    0.1,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 10.0,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 2.0),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.bold,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          googleSansText(
            text: title,
            colors: ConstantColor.paragraphTextSecondary,
            fontWeight: FontWeight.w500,
            size: 12.0,
          ),
          const SizedBox(height: 4.0),
          googleSansText(
            text: value,
            colors: ConstantColor.headingTextPrimary,
            fontWeight: FontWeight.bold,
            size: 16.0,
          ),
        ],
      ),
    );
  }
}
