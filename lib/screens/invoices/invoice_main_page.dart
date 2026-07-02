import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/screens/invoices/new/add_invoice_page.dart';
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

class _InvoiceMainPageState extends State<InvoiceMainPage> with SingleTickerProviderStateMixin {

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
      floatingActionButton: FloatingActionButton(
        onPressed: () => slideUpWidget(newPage: AddInvoicePage(), context: context),
        backgroundColor: ConstantColor.blueBackground,
        child: Icon(
          Platform.isAndroid ? Icons.add : CupertinoIcons.add,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              googleSansText(text: "Invoices", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 24.0, textAlign: TextAlign.center, softWrap: true),
              SizedBox(height: 16.0,),
              SizedBox(
                height: 100,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          border: BoxBorder.all(color: ConstantColor.blueBackground.withAlpha(50)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            googleSansText(text: "Total Outstanding", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 11.0, textAlign: TextAlign.center, softWrap: true),
                            SizedBox(height: 10.0,),
                            googleSansText(text: "₦1,245,000", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 20.0, textAlign: TextAlign.center, softWrap: true),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12.0,),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          border: BoxBorder.all(color: ConstantColor.blueBackground.withAlpha(50)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            googleSansText(text: "Overdue", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 11.0, textAlign: TextAlign.center, softWrap: true),
                            SizedBox(height: 10.0,),
                            googleSansText(text: "₦1,245,000", colors: Colors.red, fontWeight: FontWeight.bold, size: 20.0, textAlign: TextAlign.center, softWrap: true),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.0,),
              Container(
                padding: const EdgeInsets.all(16.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: ConstantColor.blueBackground,
                  borderRadius: BorderRadius.circular(10.0),
                  border: BoxBorder.all(color: ConstantColor.blueBackground.withAlpha(50)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        googleSansText(text: "Collected This Month", colors: ConstantColor.lightBackground, fontWeight: FontWeight.bold, size: 11.0, textAlign: TextAlign.center, softWrap: true),
                        SizedBox(height: 10.0,),
                        googleSansText(text: "₦850,000", colors: Colors.white, fontWeight: FontWeight.bold, size: 30.0, textAlign: TextAlign.center, softWrap: true),
                      ],
                    ),
                    Icon(Platform.isAndroid
                        ? Icons.show_chart
                        : CupertinoIcons.graph_circle, color: Colors.white,),
                  ],
                ),
              ),
              SizedBox(height: 24.0,),
              SearchBar(
                hintText: "Search customer or invoice #",
                hintStyle: WidgetStatePropertyAll(TextStyle(fontFamily: "googleSans", color: ConstantColor.paragraphTextSecondary)),
                backgroundColor: WidgetStatePropertyAll(Colors.white),
                elevation: WidgetStatePropertyAll(0.0),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
                side: WidgetStateProperty.all(BorderSide(color: ConstantColor.paragraphTextSecondary.withAlpha(50),)),
              ),
              SizedBox(height: 16.0,),
              DefaultTabController(
                initialIndex: 0,
                length: myTabs.length,
                child: SizedBox(
                  height: 40,
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: TabBar(
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontFamily: "googleSans",
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      dividerColor: Colors.transparent,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: ConstantColor.blueBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 12,
                        fontFamily: "googleSans",
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w400,
                        color: ConstantColor.paragraphTextPrimary,
                      ),
                      controller: tabController,
                      tabs: myTabs,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: TabBarView(
                  controller: tabController,
                  children: [
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
