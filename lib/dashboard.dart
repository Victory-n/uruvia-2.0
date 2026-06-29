import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/screens/business/business_health.dart';
import 'package:uruvia/screens/expenses/expense_list_page.dart';
import 'package:uruvia/welcome/data_sync.dart';
import 'package:uruvia/widgets/custom_column_heading_text.dart';
import 'package:uruvia/widgets/custom_text.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
            ),
            SizedBox(width: 12.0,),
            interText(text: "Uruvia", colors: Colors.black, fontWeight: FontWeight.bold, size: 20.0, textAlign: TextAlign.center, softWrap: true),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Platform.isAndroid ? Icon(Icons.cloud_done_outlined, color: ConstantColor.paragraphTextPrimary,) : Icon(CupertinoIcons.cloud_upload, color: ConstantColor.paragraphTextPrimary,),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
                    child: columnText(
                      headingText: interText(text: "Welcome Ada", colors: Colors.black, fontWeight: FontWeight.w600, size: 24.0, textAlign: TextAlign.center, softWrap: true),
                      subtext: googleSansText(text: "Your business command centre is ready.", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.normal, size: 14.0, textAlign: TextAlign.center, softWrap: true),
                    ),
                  ),
                ),
                SizedBox(height: 24.0,),
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset("assets/img/rocket.png"),
                      SizedBox(height: 16.0,),
                      columnText(
                        headingText: interText(text: "Let's get down to business", colors: Colors.black, fontWeight: FontWeight.bold, size: 30.0, textAlign: TextAlign.center, softWrap: true),
                        subtext: googleSansText(text: "Start by adding your first invoice, expense, or product to see your business health and insights here.", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.normal, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                      ),
                      SizedBox(height: 16.0,),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () => slideRightWidget(newPage: DataSyncPage(), context: context,),
                              style: ButtonStyle(
                                fixedSize: WidgetStateProperty.all(Size(MediaQuery.of(context).size.width, 44.0)),
                                backgroundColor: WidgetStateProperty.all(ConstantColor.blueBackground),
                                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Platform.isAndroid ? Icon(Icons.add, color: Colors.white, size: 16.0,) : Icon(CupertinoIcons.add, color: Colors.white, size: 16.0,),
                                  SizedBox(width: 5.0,),
                                  interText(text: "Create Invoice", colors: Colors.white, fontWeight: FontWeight.w700, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.0,),
                            ElevatedButton(
                              onPressed: () => slideRightWidget(newPage: ExpenseListPage(), context: context,),
                              style: ButtonStyle(
                                fixedSize: WidgetStateProperty.all(Size(MediaQuery.of(context).size.width, 44.0)),
                                backgroundColor: WidgetStateProperty.all(Colors.white),
                                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0), side: BorderSide(color: Colors.black, width: 1.0,),)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Platform.isAndroid ? Icon(Icons.receipt, color: Colors.black, size: 16.0,) : Icon(CupertinoIcons.news, color: Colors.black, size: 16.0,),
                                  SizedBox(width: 5.0,),
                                  interText(text: "Log Expense", colors: Colors.black, fontWeight: FontWeight.w700, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.0,),
                            ElevatedButton(
                              onPressed: () => slideRightWidget(newPage: ExpenseListPage(), context: context,),
                              style: ButtonStyle(
                                fixedSize: WidgetStateProperty.all(Size(MediaQuery.of(context).size.width, 44.0)),
                                backgroundColor: WidgetStateProperty.all(Colors.white),
                                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0), side: BorderSide(color: Colors.black, width: 1.0,),)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Platform.isAndroid ? Icon(Icons.receipt, color: Colors.black, size: 16.0,) : Icon(CupertinoIcons.news, color: Colors.black, size: 16.0,),
                                  SizedBox(width: 5.0,),
                                  interText(text: "Record Sales", colors: Colors.black, fontWeight: FontWeight.w700, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.0,),
                Container(
                  height: 128.0,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(20.0),
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Platform.isAndroid ? Icon(Icons.account_balance_wallet, color: ConstantColor.paragraphTextPrimary, size: 13.0,) : Icon(CupertinoIcons.money_dollar, color: ConstantColor.paragraphTextPrimary, size: 13.0,),
                          SizedBox(width: 8.0,),
                          interText(text: "Total Revenue", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 12.0, textAlign: TextAlign.center, softWrap: true),
                        ],
                      ),
                      Spacer(),
                      interText(text: "₦0.00", colors: Color(0xFFC6C6CD), fontWeight: FontWeight.bold, size: 30.0, textAlign: TextAlign.center, softWrap: true),
                    ],
                  ),
                ),
                SizedBox(height: 12.0,),
                Container(
                  height: 128.0,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(20.0),
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Platform.isAndroid ? Icon(Icons.credit_card, color: ConstantColor.paragraphTextPrimary, size: 13.0,) : Icon(CupertinoIcons.creditcard, color: ConstantColor.paragraphTextPrimary, size: 13.0,),
                          SizedBox(width: 8.0,),
                          interText(text: "Total Expense", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 12.0, textAlign: TextAlign.center, softWrap: true),
                        ],
                      ),
                      Spacer(),
                      interText(text: "₦0.00", colors: Color(0xFFC6C6CD), fontWeight: FontWeight.bold, size: 30.0, textAlign: TextAlign.center, softWrap: true),
                    ],
                  ),
                ),
                SizedBox(height: 12.0,),
                Container(
                  height: 128.0,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(20.0),
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Platform.isAndroid ? Icon(Icons.trending_up, color: ConstantColor.paragraphTextPrimary, size: 13.0,) : Icon(CupertinoIcons.graph_square, color: ConstantColor.paragraphTextPrimary, size: 13.0,),
                          SizedBox(width: 8.0,),
                          interText(text: "Net Profit", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 12.0, textAlign: TextAlign.center, softWrap: true),
                        ],
                      ),
                      Spacer(),
                      interText(text: "--", colors: Color(0xFFC6C6CD), fontWeight: FontWeight.bold, size: 30.0, textAlign: TextAlign.center, softWrap: true),
                    ],
                  ),
                ),
                SizedBox(height: 24.0,),
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Platform.isAndroid ? Icon(Icons.health_and_safety_outlined, color: ConstantColor.paragraphTextPrimary, size: 20.0,) : Icon(CupertinoIcons.shield, color: ConstantColor.paragraphTextPrimary, size: 20.0,),
                          SizedBox(width: 8.0,),
                          interText(text: "Business Health Score", colors: Colors.black, fontWeight: FontWeight.w600, size: 18.0, textAlign: TextAlign.center, softWrap: true),
                        ],
                      ),
                      SizedBox(height: 16.0,),
                      GestureDetector(
                        onTap: () => slideRightWidget(newPage: BusinessHealthPage(), context: context),
                        child: Container(
                          height: 192,
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: Color(0xFFC6C6CD), width: 1.0,),
                            color: Color(0xFFEFF4FF),
                          ),
                          child: Column(
                            children: [
                              SvgPicture.asset("assets/svg/graph_search.svg"),
                              Spacer(),
                              interText(text: "Score will calculate after your first few entries. Keep adding data to unlock insights.", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.normal, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.0,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0,),
                  child: interText(text: "Quick Start", colors: Colors.black, fontWeight: FontWeight.w600, size: 18.0, textAlign: TextAlign.center, softWrap: true),
                ),
                SizedBox(height: 10.0,),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Color(0xFF2170E4).withAlpha(80),
                                child: Center(
                                  child: Platform.isAndroid ? Icon(Icons.add, color: Color(0xFF0058BE), size: 30.0,) : Icon(CupertinoIcons.add, color: Color(0xFF0058BE), size: 30.0,),
                                ),
                              ),
                              SizedBox(width: 12.0,),
                              Expanded(
                                child: columnText(
                                  headingText: interText(text: "Create your first invoice", colors: Colors.black, fontWeight: FontWeight.w600, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                                  subtext: googleSansText(text: "Bill a client for your services", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.w600, size: 14.0, textAlign: TextAlign.center, softWrap: true),
                                ),
                              ),
                              Platform.isAndroid ? Icon(Icons.arrow_forward_ios, color: ConstantColor.paragraphTextSecondary, size: 12.0,) : Icon(CupertinoIcons.right_chevron, color: ConstantColor.paragraphTextSecondary, size: 12.0,),
                            ],
                          ),
                        ),
                      ),
                      const Divider(),
                      GestureDetector(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Color(0xFF2170E4).withAlpha(80),
                                child: Center(
                                  child: Platform.isAndroid ? Icon(Icons.receipt, color: Color(0xFF0058BE), size: 30.0,) : Icon(CupertinoIcons.news, color: Color(0xFF0058BE), size: 30.0,),
                                ),
                              ),
                              SizedBox(width: 12.0,),
                              Expanded(
                                child: columnText(
                                  headingText: interText(text: "Log a business expense", colors: Colors.black, fontWeight: FontWeight.w600, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                                  subtext: googleSansText(text: "Track your outgoing costs", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.w600, size: 14.0, textAlign: TextAlign.center, softWrap: true),
                                ),
                              ),
                              Platform.isAndroid ? Icon(Icons.arrow_forward_ios, color: ConstantColor.paragraphTextSecondary, size: 12.0,) : Icon(CupertinoIcons.right_chevron, color: ConstantColor.paragraphTextSecondary, size: 12.0,),
                            ],
                          ),
                        ),
                      ),
                      const Divider(),
                      GestureDetector(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Color(0xFF2170E4).withAlpha(80),
                                child: Center(
                                  child: Platform.isAndroid ? Icon(Icons.inventory_2_outlined, color: Color(0xFF0058BE), size: 30.0,) : Icon(CupertinoIcons.archivebox, color: Color(0xFF0058BE), size: 30.0,),
                                ),
                              ),
                              SizedBox(width: 12.0,),
                              Expanded(
                                child: columnText(
                                  headingText: interText(text: "Add a product to inventory", colors: Colors.black, fontWeight: FontWeight.w600, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                                  subtext: googleSansText(text: "Set up items you sell", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.w600, size: 14.0, textAlign: TextAlign.center, softWrap: true),
                                ),
                              ),
                              Platform.isAndroid ? Icon(Icons.arrow_forward_ios, color: ConstantColor.paragraphTextSecondary, size: 12.0,) : Icon(CupertinoIcons.right_chevron, color: ConstantColor.paragraphTextSecondary, size: 12.0,),
                            ],
                          ),
                        ),
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
}
