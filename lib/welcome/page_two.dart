import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:uruvia/welcome/page_three.dart';
import '../constants/colors.dart';
import '../widgets/custom_text.dart';

class PageTwo extends StatelessWidget {
  const PageTwo({super.key});

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
                      backgroundColor: ConstantColor.paragraphTextPrimary.withAlpha(50),
                    ),
                    CircleAvatar(
                      radius: 5,
                      backgroundColor: Colors.black,
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
                slideRightWidget(newPage: PageThree(), context: context,);
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
                  child: Image.asset("assets/img/disconnected.png"),
                ),
              ),
              Spacer(),
              FittedBox(
                fit: BoxFit.contain,
                child: interText(text: "Work Offline, Sync Later", colors: Colors.black, fontWeight: FontWeight.w700, size: 24.0, textAlign: TextAlign.center, softWrap: true),
              ),
              SizedBox(height: 12.0,),
              Flexible(
                fit: FlexFit.loose,
                child: googleSansText(text: "Manage your business anywhere, even without internet. Your data syncs automatically when you're back online.", colors: Colors.black, fontWeight: FontWeight.normal, size: 16.0, textAlign: TextAlign.center, softWrap: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
