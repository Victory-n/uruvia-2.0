import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/side_bar.dart';

import '../widgets/custom_text.dart';

class DataSyncPage extends StatelessWidget {
  const DataSyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
            color: Colors.white,
            child: Column(
              children: [
                Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      SvgPicture.asset("assets/svg/cloud.svg"),
                      SizedBox(height: 12.0,),
                      interText(text: "Data Synchronized", colors: ConstantColor.headingTextPrimary, fontWeight: FontWeight.w700, size: 24.0, textAlign: TextAlign.center, softWrap: true),
                      SizedBox(height: 12.0,),
                      googleSansText(text: "Ready for offline use. Your business command centre is fully updated.", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.normal, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                    ],
                  ),
                ),
                SizedBox(height: 24.0,),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Color(0xFFEFF4FF),
                    border: Border.all(color: ConstantColor.paragraphTextPrimary.withAlpha(50), width: 1.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      interText(text: "SYNC SUMMARY", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.w700, size: 12.0, textAlign: TextAlign.center, softWrap: true),
                      SizedBox(height: 16.0,),
                      Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)),),
                        elevation: 0.0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset("assets/svg/inventory.svg"),
                                  SizedBox(width: 12.0,),
                                  interText(text: "Products & Inventory", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.w600, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                                ],
                              ),
                              Platform.isAndroid ? Icon(Icons.check_circle, color: Colors.green,) : Icon(Icons.check_circle_outline, color: Colors.green,),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12.0,),
                      Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)),),
                        elevation: 0.0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset("assets/svg/receipt.svg"),
                                  SizedBox(width: 12.0,),
                                  interText(text: "Recent Invoices", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.w600, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                                ],
                              ),
                              Platform.isAndroid ? Icon(Icons.check_circle, color: Colors.green,) : Icon(Icons.check_circle_outline, color: Colors.green,),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12.0,),
                      Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)),),
                        elevation: 0.0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset("assets/svg/contact.svg"),
                                  SizedBox(width: 12.0,),
                                  interText(text: "Client Directory", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.w600, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                                ],
                              ),
                              Platform.isAndroid ? Icon(Icons.check_circle, color: Colors.green,) : Icon(Icons.check_circle_outline, color: Colors.green,),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.0,),
                Spacer(),
                FittedBox(
                  child: ElevatedButton(
                    onPressed: () => slideRightWidget(newPage: SideBarPage(title: ""), context: context,),
                    style: ButtonStyle(
                      fixedSize: WidgetStateProperty.all(Size(MediaQuery.of(context).size.width, 60.0)),
                      backgroundColor: WidgetStateProperty.all(ConstantColor.headingTextPrimary),
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        interText(text: "Proceed to Dashboard", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.w700, size: 18.0, textAlign: TextAlign.center, softWrap: true),
                        Icon(Icons.arrow_forward, color: ConstantColor.paragraphTextSecondary, size: 18.0,),
                      ],
                    ),
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
