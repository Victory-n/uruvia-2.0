import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/screens/invoices/add_invoice_page.dart';
import 'package:uruvia/screens/invoices/tabs/all_page.dart';
import 'package:uruvia/screens/invoices/tabs/draft_page.dart';
import 'package:uruvia/screens/invoices/tabs/overdue_page.dart';
import 'package:uruvia/screens/invoices/tabs/paid_page.dart';

import '../../widgets/custom_text.dart';

class InvoiceMainPage extends StatefulWidget {
  const InvoiceMainPage({super.key});

  @override
  State<InvoiceMainPage> createState() => _InvoiceMainPageState();
}

class _InvoiceMainPageState extends State<InvoiceMainPage>
    with SingleTickerProviderStateMixin {
  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'All'),
    Tab(text: 'Draft'),
    Tab(text: 'Overdue'),
    Tab(text: 'Paid'),
  ];
  TabController? tabController;

  @override
  void initState() {
    tabController = TabController(vsync: this, length: myTabs.length);
    super.initState();
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
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
          text: "Invoices",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 22.0,
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            slideUpWidget(newPage: const AddInvoicePage(), context: context),
        backgroundColor: ConstantColor.blueBackground,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
        ),
        icon: const Icon(CupertinoIcons.add, color: Colors.white, size: 20.0),
        label: googleSansText(
          text: "Create",
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

              // 1. Two Metrics Card (Outstanding & Overdue)
              Row(
                children: [
                  // Outstanding
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
                      child: Row(
                        children: [
                          Container(
                            width: 32.0,
                            height: 32.0,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFF9E6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              CupertinoIcons.doc_plaintext,
                              size: 16.0,
                              color: Color(0xFFD48C00),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                googleSansText(
                                  text: "Outstanding",
                                  colors: ConstantColor.paragraphTextSecondary,
                                  fontWeight: FontWeight.bold,
                                  size: 10.0,
                                ),
                                const SizedBox(height: 2.0),
                                googleSansText(
                                  text: "₦1,245,000",
                                  colors: ConstantColor.headingTextPrimary,
                                  fontWeight: FontWeight.w900,
                                  size: 14.0,
                                  softWrap: false,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  // Overdue
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
                      child: Row(
                        children: [
                          Container(
                            width: 32.0,
                            height: 32.0,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFEBEE),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              CupertinoIcons.shield,
                              size: 16.0,
                              color: Color(0xFFC62828),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                googleSansText(
                                  text: "Overdue",
                                  colors: ConstantColor.paragraphTextSecondary,
                                  fontWeight: FontWeight.bold,
                                  size: 10.0,
                                ),
                                const SizedBox(height: 2.0),
                                googleSansText(
                                  text: "₦1,245,000",
                                  colors: const Color(0xFFC62828),
                                  fontWeight: FontWeight.w900,
                                  size: 14.0,
                                  softWrap: false,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // 2. Collected Card with beautiful Gradient
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18.0,
                  vertical: 16.0,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [ConstantColor.blueBackground, Color(0xFF0075FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: ConstantColor.blueBackground.withOpacity(0.2),
                      blurRadius: 12.0,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        googleSansText(
                          text: "Collected This Month",
                          colors: Colors.white.withOpacity(0.85),
                          fontWeight: FontWeight.bold,
                          size: 11.0,
                        ),
                        const SizedBox(height: 4.0),
                        googleSansText(
                          text: "₦850,000",
                          colors: Colors.white,
                          fontWeight: FontWeight.w900,
                          size: 26.0,
                        ),
                        const SizedBox(height: 4.0),
                        Row(
                          children: [
                            const Icon(
                              Icons.trending_up_rounded,
                              size: 14.0,
                              color: Colors.greenAccent,
                            ),
                            const SizedBox(width: 4.0),
                            googleSansText(
                              text: "+12.4% from last month",
                              colors: Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.normal,
                              size: 11.0,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      width: 44.0,
                      height: 44.0,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.graph_square,
                        color: Colors.white,
                        size: 22.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),

              // 3. Custom Styled Search Bar
              Container(
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
                  decoration: InputDecoration(
                    hintText: "Search customer or invoice #",
                    hintStyle: TextStyle(
                      fontFamily: "googleSans",
                      color: ConstantColor.paragraphTextSecondary.withOpacity(
                        0.6,
                      ),
                      fontSize: 14.0,
                    ),
                    prefixIcon: Icon(
                      CupertinoIcons.search,
                      color: ConstantColor.paragraphTextSecondary.withOpacity(
                        0.6,
                      ),
                      size: 18.0,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  style: const TextStyle(
                    fontFamily: "googleSans",
                    fontSize: 14.0,
                    color: ConstantColor.headingTextPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // 4. TabBar inside clean Box
              SizedBox(
                height: 44.0,
                child: TabBar(
                  controller: tabController,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: ConstantColor.blueBackground,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: ConstantColor.blueBackground.withOpacity(0.15),
                        blurRadius: 6.0,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: ConstantColor.paragraphTextPrimary,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontFamily: "googleSans",
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                    fontFamily: "googleSans",
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: myTabs,
                ),
              ),
              const SizedBox(height: 8.0),

              // 5. TabBarView for list contents
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: const [
                    AllPage(),
                    DraftPage(),
                    OverduePage(),
                    PaidPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
