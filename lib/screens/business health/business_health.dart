import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/screens/inventory/inventory_main_page.dart';
import 'package:uruvia/screens/invoices/invoice_main_page.dart';
import 'package:uruvia/widgets/custom_text.dart';

class BusinessHealthPage extends StatefulWidget {
  const BusinessHealthPage({super.key});

  @override
  State<BusinessHealthPage> createState() => _BusinessHealthPageState();
}

class _BusinessHealthPageState extends State<BusinessHealthPage> {
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
                icon: const Icon(CupertinoIcons.bars, color: ConstantColor.headingTextPrimary),
                onPressed: () => Scaffold.maybeOf(context)?.openDrawer(),
              ),
        title: googleSansText(
          text: "Business Health",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 20.0,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: googleSansText(
                    text: "Insights are updated in real-time.",
                    colors: Colors.white,
                    fontWeight: FontWeight.normal,
                    size: 14.0,
                  ),
                  backgroundColor: ConstantColor.blueBackground,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            icon: Icon(
              Platform.isAndroid ? Icons.cloud_done_outlined : CupertinoIcons.cloud_upload,
              color: ConstantColor.blueBackground,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Title Block
                googleSansText(
                  text: "Business Health Score",
                  colors: ConstantColor.headingTextPrimary,
                  fontWeight: FontWeight.bold,
                  size: 24.0,
                ),
                const SizedBox(height: 4.0),
                googleSansText(
                  text: "Your overall operational efficiency and financial standing.",
                  colors: ConstantColor.paragraphTextSecondary,
                  fontWeight: FontWeight.normal,
                  size: 14.0,
                ),
                const SizedBox(height: 20.0),

                // 2. Current Status Circular Chart Card
                Container(
                  width: double.infinity,
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
                    children: [
                      // Top Green Accent Border Decoration
                      Container(
                        height: 4.0,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0D9488), // Teal Status color
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            topRight: Radius.circular(16.0),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            googleSansText(
                              text: "Current Status",
                              colors: ConstantColor.headingTextPrimary,
                              fontWeight: FontWeight.bold,
                              size: 16.0,
                            ),
                            const SizedBox(height: 20.0),
                            // Circular Indicator Centered
                            Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 140.0,
                                    height: 140.0,
                                    child: CircularProgressIndicator(
                                      value: 0.72,
                                      strokeWidth: 12.0,
                                      backgroundColor: const Color(0xFFE2E8F0),
                                      valueColor: const AlwaysStoppedAnimation<Color>(ConstantColor.blueBackground),
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      googleSansText(
                                        text: "72",
                                        colors: ConstantColor.headingTextPrimary,
                                        fontWeight: FontWeight.w900,
                                        size: 36.0,
                                      ),
                                      googleSansText(
                                        text: "FAIR",
                                        colors: ConstantColor.paragraphTextSecondary,
                                        fontWeight: FontWeight.bold,
                                        size: 12.0,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            // Description text
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: googleSansText(
                                  text: "Your score is stable, but immediate action on overdue items can boost it to Good.",
                                  colors: ConstantColor.paragraphTextSecondary,
                                  fontWeight: FontWeight.normal,
                                  size: 13.0,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),

                // 3. Factor Breakdown Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
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
                      Row(
                        children: [
                          const Icon(CupertinoIcons.square_grid_2x2, color: ConstantColor.headingTextPrimary, size: 18.0),
                          const SizedBox(width: 8.0),
                          googleSansText(
                            text: "Factor Breakdown",
                            colors: ConstantColor.headingTextPrimary,
                            fontWeight: FontWeight.bold,
                            size: 16.0,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),

                      // Item 1: Expense Regularity
                      _buildFactorRow(
                        icon: CupertinoIcons.graph_square,
                        iconColor: const Color(0xFF0288D1),
                        iconBg: const Color(0xFFE1F5FE),
                        title: "Expense Regularity",
                        subtitle: "Consistent tracking",
                        points: "+10 pts",
                        pointsColor: const Color(0xFF2E7D32),
                      ),
                      const Divider(color: Color(0xFFF1F5F9), height: 24.0, indent: 44.0),

                      // Item 2: Overdue Invoices
                      _buildFactorRow(
                        icon: CupertinoIcons.exclamationmark_triangle,
                        iconColor: const Color(0xFFC62828),
                        iconBg: const Color(0xFFFFEBEE),
                        title: "Overdue Invoices",
                        subtitle: "3 invoices pending",
                        points: "-15 pts",
                        pointsColor: const Color(0xFFC62828),
                      ),
                      const Divider(color: Color(0xFFF1F5F9), height: 24.0, indent: 44.0),

                      // Item 3: Stockouts
                      _buildFactorRow(
                        icon: CupertinoIcons.archivebox,
                        iconColor: const Color(0xFFE65100),
                        iconBg: const Color(0xFFFFE0B2),
                        title: "Stockouts",
                        subtitle: "1 item out of stock",
                        points: "-5 pts",
                        pointsColor: const Color(0xFFC62828),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),

                // 4. Weekly Trend Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(CupertinoIcons.graph_square, color: ConstantColor.headingTextPrimary, size: 18.0),
                              const SizedBox(width: 8.0),
                              googleSansText(
                                text: "Weekly Trend",
                                colors: ConstantColor.headingTextPrimary,
                                fontWeight: FontWeight.bold,
                                size: 16.0,
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: googleSansText(
                              text: "Past 4 Weeks",
                              colors: ConstantColor.blueBackground,
                              fontWeight: FontWeight.bold,
                              size: 11.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),
                      // Graphical simulator columns row
                      SizedBox(
                        height: 100.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildTrendBar("W1", 45.0, false),
                            _buildTrendBar("W2", 65.0, false),
                            _buildTrendBar("W3", 52.0, false),
                            _buildTrendBar("W4", 78.0, true), // Active current week
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),

                // 5. Actionable Tips Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
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
                      Row(
                        children: [
                          const Icon(CupertinoIcons.lightbulb, color: ConstantColor.headingTextPrimary, size: 18.0),
                          const SizedBox(width: 8.0),
                          googleSansText(
                            text: "Actionable Tips",
                            colors: ConstantColor.headingTextPrimary,
                            fontWeight: FontWeight.bold,
                            size: 16.0,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),

                      // Tip 1: Resolve Overdue
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBFBFE),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: const Color(0xFFEFF3FF)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(CupertinoIcons.doc_text_fill, color: Color(0xFFC62828), size: 16.0),
                                const SizedBox(width: 8.0),
                                googleSansText(
                                  text: "Resolve Overdue Invoices",
                                  colors: ConstantColor.headingTextPrimary,
                                  fontWeight: FontWeight.bold,
                                  size: 14.0,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            googleSansText(
                              text: "Pay 2 overdue invoices to regain 10 points and improve cash flow reliability.",
                              colors: ConstantColor.paragraphTextSecondary,
                              fontWeight: FontWeight.normal,
                              size: 12.5,
                            ),
                            const SizedBox(height: 12.0),
                            SizedBox(
                              width: double.infinity,
                              height: 38.0,
                              child: ElevatedButton(
                                onPressed: () => slideRightWidget(newPage: const InvoiceMainPage(), context: context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F172A), // Dark Navy
                                  foregroundColor: Colors.white,
                                  elevation: 0.0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    googleSansText(text: "View Overdue", colors: Colors.white, fontWeight: FontWeight.bold, size: 13.0),
                                    const SizedBox(width: 4.0),
                                    const Icon(CupertinoIcons.arrow_right, size: 12.0, color: Colors.white),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 14.0),

                      // Tip 2: Prevent Stockout
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBFBFE),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: const Color(0xFFEFF3FF)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(CupertinoIcons.archivebox_fill, color: Color(0xFFE65100), size: 16.0),
                                const SizedBox(width: 8.0),
                                googleSansText(
                                  text: "Prevent Stockout",
                                  colors: ConstantColor.headingTextPrimary,
                                  fontWeight: FontWeight.bold,
                                  size: 14.0,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            googleSansText(
                              text: "Reorder Sugar immediately to avoid operational disruption and regain points.",
                              colors: ConstantColor.paragraphTextSecondary,
                              fontWeight: FontWeight.normal,
                              size: 12.5,
                            ),
                            const SizedBox(height: 12.0),
                            SizedBox(
                              width: double.infinity,
                              height: 38.0,
                              child: OutlinedButton(
                                onPressed: () => slideRightWidget(newPage: const InventoryMainPage(), context: context),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF0F172A), width: 1.2),
                                  foregroundColor: const Color(0xFF0F172A),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    googleSansText(text: "Go to Inventory", colors: const Color(0xFF0F172A), fontWeight: FontWeight.bold, size: 13.0),
                                    const SizedBox(width: 4.0),
                                    const Icon(CupertinoIcons.arrow_right, size: 12.0, color: Color(0xFF0F172A)),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Factor breakdown row helper
  Widget _buildFactorRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String points,
    required Color pointsColor,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18.0,
          backgroundColor: iconBg,
          child: Icon(icon, color: iconColor, size: 18.0),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              googleSansText(
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
                size: 11.5,
              ),
            ],
          ),
        ),
        googleSansText(
          text: points,
          colors: pointsColor,
          fontWeight: FontWeight.bold,
          size: 14.0,
        ),
      ],
    );
  }

  // Weekly Trend simulated bar widget helper
  Widget _buildTrendBar(String weekName, double valHeight, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 32.0,
          height: valHeight,
          decoration: BoxDecoration(
            color: isActive ? ConstantColor.blueBackground : const Color(0xFFEFF4FF),
            borderRadius: BorderRadius.circular(6.0),
          ),
        ),
        const SizedBox(height: 8.0),
        googleSansText(
          text: weekName,
          colors: isActive ? ConstantColor.headingTextPrimary : ConstantColor.paragraphTextSecondary,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          size: 11.0,
        ),
      ],
    );
  }
}
