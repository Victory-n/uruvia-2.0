import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/welcome/page_three.dart';
import 'package:uruvia/welcome/page_two.dart';
import 'package:uruvia/widgets/custom_text.dart';

class PageOne extends StatelessWidget {
  const PageOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        height: 70.0,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                if (kDebugMode) {
                  print("Pressed!!");
                }
                slideRightWidget(newPage: PageThree(), context: context,);
              },
              child: Text(
                "Skip",
                style: TextStyle(
                  fontFamily: "Inter",
                  fontWeight: FontWeight.bold,
                  color: ConstantColor.paragraphTextPrimary,
                  fontSize: 16.0,
                ),
              ),
            ),
            Flexible(
              child: SizedBox(
                width: 40.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 5,
                      backgroundColor: Colors.black,
                    ),
                    CircleAvatar(
                      radius: 5,
                      backgroundColor: ConstantColor.paragraphTextPrimary.withAlpha(50),
                    ),
                    CircleAvatar(
                      radius: 5,
                      backgroundColor: ConstantColor.paragraphTextPrimary.withAlpha(50),
                    ),
                  ],
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (kDebugMode) {
                  print("Pressed!!");
                }
                slideRightWidget(newPage: PageTwo(), context: context,);
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.black),
                padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0)),
              ),
              child: Text(
                "Next",
                style: TextStyle(
                  fontFamily: "Inter",
                  fontWeight: FontWeight.bold,
                  color: ConstantColor.lightBackground,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
          child: Column(
            children: [
              Spacer(),
              FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  height: 200.0,
                  width: 200.0,
                  child: Image.asset("assets/img/invoice.png"),
                ),
              ),
              Spacer(),
              FittedBox(
                fit: BoxFit.contain,
                child: interText(text: "Smart Invoicing & Expenses", colors: Colors.black, fontWeight: FontWeight.w700, size: 24.0, textAlign: TextAlign.center, softWrap: true),
              ),
              SizedBox(height: 12.0,),
              Flexible(
                fit: FlexFit.loose,
                child: googleSansText(text: "Create professional invoices in seconds and log expenses with your voice. Keep your cash flow organized effortlessly.", colors: Colors.black, fontWeight: FontWeight.normal, size: 16.0, textAlign: TextAlign.center, softWrap: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
