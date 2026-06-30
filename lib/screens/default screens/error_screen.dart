import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../constants/colors.dart';
import '../../widgets/custom_text.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Spacer(),
                SvgPicture.asset("assets/svg/error.svg"),
                SizedBox(height: 24.0,),
                googleSansText(text: "Something went wrong", colors: Colors.black, fontWeight: FontWeight.bold, size: 30.0, textAlign: TextAlign.center, softWrap: true),
                SizedBox(height: 16.0,),
                googleSansText(text: "We couldn't complete the action. This might be due to a temporary sync issue or a lost connection", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                SizedBox(height: 40.0,),
                FittedBox(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      fixedSize: WidgetStateProperty.all(Size(MediaQuery.of(context).size.width, 60.0)),
                      backgroundColor: WidgetStateProperty.all(Colors.black),
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Platform.isAndroid
                            ? Icons.refresh
                            : CupertinoIcons.refresh,
                          color: Colors.white, size: 18.0,),
                        SizedBox(width: 10,),
                        googleSansText(text: "Try Again", colors: Colors.white, fontWeight: FontWeight.w700, size: 18.0, textAlign: TextAlign.center, softWrap: true),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                FittedBox(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ButtonStyle(
                        fixedSize: WidgetStateProperty.all(Size(MediaQuery.of(context).size.width, 60.0)),
                        backgroundColor: WidgetStateProperty.all(Colors.white),
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
                        side: WidgetStateProperty.all(BorderSide(color: Colors.black,))
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Platform.isAndroid
                            ? Icons.save
                            : CupertinoIcons.floppy_disk,
                          color: Colors.black, size: 18.0,),
                        SizedBox(width: 10,),
                        googleSansText(text: "Save as Draft (Offline)", colors: Colors.black, fontWeight: FontWeight.w700, size: 18.0, textAlign: TextAlign.center, softWrap: true),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.0,),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Platform.isAndroid
                          ? Icons.help_outline
                          : CupertinoIcons.question_circle,
                        color: ConstantColor.blueBackground, size: 18.0,),
                      SizedBox(width: 7,),
                      googleSansText(text: "Contact Support", colors: ConstantColor.blueBackground, fontWeight: FontWeight.w700, size: 14.0, textAlign: TextAlign.center, softWrap: true),
                    ],
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
