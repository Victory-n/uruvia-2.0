import 'package:flutter/material.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:uruvia/screens/auth_screens/auto_login.dart';
import '../constants/colors.dart';
import '../widgets/custom_text.dart';

class PageThree extends StatelessWidget {
  const PageThree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        height: 70.0,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: ElevatedButton(
          onPressed: () => slideRightWidget(newPage: AutoLogin(), context: context,),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(ConstantColor.blueBackground),
          ),
          child: interText(text: "GET STARTED", colors: Colors.white, fontWeight: FontWeight.w700, size: 12.0, textAlign: TextAlign.center, softWrap: true),
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
                  child: Image.asset("assets/img/health-insurance.png"),
                ),
              ),
              Spacer(),
              FittedBox(
                fit: BoxFit.contain,
                child: interText(text: "Your Business Health at a Glance", colors: Colors.black, fontWeight: FontWeight.w700, size: 24.0, textAlign: TextAlign.center, softWrap: true),
              ),
              SizedBox(height: 12.0,),
              Flexible(
                fit: FlexFit.loose,
                child: googleSansText(text: "Track your business health score and get actionable insights to grow your revenue and stay on top of overdue payments.", colors: Colors.black, fontWeight: FontWeight.normal, size: 16.0, textAlign: TextAlign.center, softWrap: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
