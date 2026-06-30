import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uruvia/screens/inventory/inventory_main_page.dart';

import '../../constants/colors.dart';
import '../../widgets/custom_text.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

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
                SvgPicture.asset("assets/svg/success.svg"),
                SizedBox(height: 24.0,),
                googleSansText(text: "Action Successful", colors: Colors.black, fontWeight: FontWeight.bold, size: 30.0, textAlign: TextAlign.center, softWrap: true),
                SizedBox(height: 16.0,),
                googleSansText(text: "Your invoice #123 has been sent successfully and is now queued for sync.", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                SizedBox(height: 40.0,),
                FittedBox(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      fixedSize: WidgetStateProperty.all(Size(MediaQuery.of(context).size.width, 60.0)),
                      backgroundColor: WidgetStateProperty.all(ConstantColor.blueBackground),
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Platform.isAndroid
                            ? Icons.check_circle_outline
                            : CupertinoIcons.check_mark_circled,
                          color: Colors.white, size: 18.0,),
                        SizedBox(width: 10,),
                        googleSansText(text: "Update Product", colors: Colors.white, fontWeight: FontWeight.w700, size: 18.0, textAlign: TextAlign.center, softWrap: true),
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
                        backgroundColor: WidgetStateProperty.all(Color(0xFFFFDAD6)),
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
                        side: WidgetStateProperty.all(BorderSide(color: Colors.red,))
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Platform.isAndroid
                            ? Icons.delete_outlined
                            : CupertinoIcons.delete,
                          color: Colors.red, size: 18.0,),
                        SizedBox(width: 10,),
                        googleSansText(text: "Delete Product", colors: Colors.red, fontWeight: FontWeight.w700, size: 18.0, textAlign: TextAlign.center, softWrap: true),
                      ],
                    ),
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
