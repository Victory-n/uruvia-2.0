import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:uruvia/constants/colors.dart';
import '../../widgets/custom_text.dart';
import 'add_expense_page.dart';

class ExpenseListPage extends StatefulWidget {
  const ExpenseListPage({super.key});

  @override
  State<ExpenseListPage> createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: SpeedDial(
      //   icon: Icons.add,
      //   activeIcon: Icons.close,
      //   backgroundColor: ConstantColor.blueBackground,
      //   foregroundColor: Colors.white,
      //   activeBackgroundColor: ConstantColor.lightBackground,
      //   activeForegroundColor: Colors.red,
      //   visible: true,
      //   closeManually: false,
      //   renderOverlay: true,
      //   overlayColor: Colors.black,
      //   overlayOpacity: 0.5,
      //   spacing: 12,
      //   spaceBetweenChildren: 12,
      //   children: [
      //     SpeedDialChild(
      //       labelWidget: Card(
      //         color: Colors.white,
      //         child: Padding(
      //           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      //           child: Row(
      //             children: [
      //               googleSansText(text: "Manual Expense", colors: Colors.black, fontWeight: FontWeight.w600, size: 15.0, textAlign: TextAlign.center, softWrap: true),
      //               Platform.isAndroid ? Icon(Icons.mic, color: Colors.green,) : Icon(CupertinoIcons.mic_fill, color: Colors.green,)
      //             ],
      //           ),
      //         ),
      //       ),
      //       onTap: () {
      //         if (kDebugMode) {
      //           print('Voice tapped');
      //         }
      //       },
      //     ),
      //     SpeedDialChild(
      //       labelWidget: Card(
      //         color: Colors.white,
      //         child: Padding(
      //           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      //           child: Row(
      //             children: [
      //               googleSansText(text: "Voice Expense", colors: Colors.black, fontWeight: FontWeight.w600, size: 15.0, textAlign: TextAlign.center, softWrap: true),
      //               Platform.isAndroid ? Icon(Icons.mic, color: Colors.green,) : Icon(CupertinoIcons.mic_fill, color: Colors.green,)
      //             ],
      //           ),
      //         ),
      //       ),
      //       onTap: () {
      //         if (kDebugMode) {
      //           print('Voice tapped');
      //         }
      //       },
      //     ),
      //   ],
      // ),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        elevation: 1.0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Platform.isAndroid ? Icon(Icons.cloud, color: Colors.black, size: 30.0,) : Icon(CupertinoIcons.cloud_fill, color: Colors.black, size: 30.0,),
          ),
        ],
        backgroundColor: Colors.white,
        title: interText(text: "Expense List", colors: Colors.black, fontWeight: FontWeight.bold, size: 20.0, textAlign: TextAlign.center, softWrap: true),
      ),
      floatingActionButton: GestureDetector(
        onTap: () => slideRightWidget(newPage: AddExpensePage(), context: context),
        child: CircleAvatar(
          radius: 30,
          backgroundColor: ConstantColor.blueBackground,
          child: Platform.isAndroid ? Icon(Icons.add, color: Colors.white, size: 30.0,) : Icon(CupertinoIcons.add, color: Colors.white, size: 30.0,),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              interText(text: "Expenses", colors: Colors.black, fontWeight: FontWeight.bold, size: 24.0, textAlign: TextAlign.center, softWrap: true),
              SizedBox(height: 12.0,),
              Container(
                padding: const EdgeInsets.all(12.0),
                height: 50.0,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Color(0xFFC6C6CD), width: 1.0,),
                  color: Colors.white,
                ),
                child: SizedBox(
                  height: 40.0,
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Platform.isAndroid ? Icon(Icons.search, color: ConstantColor.paragraphTextPrimary, size: 20.0,) : Icon(CupertinoIcons.search, color: ConstantColor.paragraphTextPrimary, size: 20.0,),
                      label: googleSansText(text: "Search by category or vendor", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.normal, size: 12.0, textAlign: TextAlign.center, softWrap: true),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.0,),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.white),
                  ),
                  onPressed: () {},
                  icon: Platform.isAndroid
                      ? Icon(Icons.filter_list, size: 30.0, color: Colors.black,)
                      : Icon(CupertinoIcons.sort_down, size: 30.0, color: Colors.black,),
                ),
              ),
              Spacer(),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      Image.asset("assets/img/capital.png", color: ConstantColor.paragraphTextSecondary, height: 50, width: 50,),
                      SizedBox(height: 12.0,),
                      googleSansText(text: "No expense entry. Click the button below to add your first expense.", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.normal, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                    ],
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
