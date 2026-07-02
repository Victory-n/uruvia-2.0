import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:route_transitions/route_transitions.dart';

import '../../../constants/colors.dart';
import '../../../widgets/custom_text.dart';

class InvoicePreviewPage extends StatefulWidget {
  const InvoicePreviewPage({super.key});

  @override
  State<InvoicePreviewPage> createState() => _InvoicePreviewPageState();
}

class _InvoicePreviewPageState extends State<InvoicePreviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        backgroundColor: Colors.white,
        title: interText(text: "Invoice Preview", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 20.0, textAlign: TextAlign.center, softWrap: true),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Platform.isAndroid ? Icon(Icons.download_rounded, color: ConstantColor.paragraphTextPrimary,) : Icon(CupertinoIcons.tray_arrow_down, color: ConstantColor.paragraphTextPrimary,),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: ConstantColor.blueBackground,
                        child: CircleAvatar(
                          radius: 49,
                          backgroundImage: AssetImage("assets/img/invoice-logo.png"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          interText(text: "720_bananabread", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 24.0),
                          const SizedBox(height: 4),
                          interText(text: "business@email.com", colors: Colors.grey, fontWeight: FontWeight.normal, size: 14.0),
                          interText(text: "+234 567 8904 745", colors: Colors.grey, fontWeight: FontWeight.normal, size: 14.0),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.0,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: interText(text: "#NV-000057", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.bold, size: 20.0, textAlign: TextAlign.center, softWrap: true),
                  ),
                ),
                Container(
                  height: 100,
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: ConstantColor.paragraphTextPrimary.withAlpha(50),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            googleSansText(text: "Invoice date", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.bold, size: 14.0, textAlign: TextAlign.center, softWrap: true),
                            googleSansText(text: "26 May 2026", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 20.0, textAlign: TextAlign.center, softWrap: true),
                          ],
                        ),
                        VerticalDivider(
                          thickness: 2,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            googleSansText(text: "Due date", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.bold, size: 14.0, textAlign: TextAlign.center, softWrap: true),
                            googleSansText(text: "26 May 2026", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 20.0, textAlign: TextAlign.center, softWrap: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      googleSansText(text: "Billed to", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.normal, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                      googleSansText(text: "Ndukwe Victory", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                    ],
                  ),
                ),
                SizedBox(height: 16,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      googleSansText(text: "ITEMS", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                      const Divider(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LimitedBox(
                        maxWidth: MediaQuery.of(context).size.width / 1.7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            googleSansText(text: "Midi Banana Bread x Chocolate chips (dark)", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.start, softWrap: true),
                            SizedBox(height: 5.0,),
                            googleSansText(text: "Qty 1.00 * 5,500.00", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.bold, size: 14.0, textAlign: TextAlign.start, softWrap: true),
                          ],
                        ),
                      ),
                      googleSansText(text: "NGN 8,200.00", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: const Divider(),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LimitedBox(
                        maxWidth: MediaQuery.of(context).size.width / 1.7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            googleSansText(text: "Delivery", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.start, softWrap: true),
                            SizedBox(height: 5.0,),
                            googleSansText(text: "Qty 1.00 * 2,700.00", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.bold, size: 14.0, textAlign: TextAlign.start, softWrap: true),
                          ],
                        ),
                      ),
                      googleSansText(text: "NGN 8,200.00", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: const Divider(),
                ),



                Container(
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.grey,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        googleSansText(text: "Balance due", colors: Colors.white, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                        googleSansText(text: "NGN 8,200.00", colors: Colors.white, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(16.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.grey,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        googleSansText(text: "Payment details", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                        googleSansText(text: "MoniePoint", colors: Colors.white, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                        googleSansText(text: "8029130533", colors: Colors.white, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                        googleSansText(text: "Ndukwe Victory", colors: Colors.white, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                      ],
                    ),
                  ),
                ),
                Align(
                  child: googleSansText(text: "Thank you for your patronage", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.bold, size: 12.0, textAlign: TextAlign.center, softWrap: true),
                ),




                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ButtonStyle(
                              fixedSize: WidgetStateProperty.all(Size(MediaQuery.of(context).size.width, 60.0)),
                              backgroundColor: WidgetStateProperty.all(Colors.white),
                              shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
                              side: WidgetStateProperty.all(BorderSide(color: ConstantColor.blueBackground,))
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Platform.isAndroid
                                  ? Icons.save
                                  : CupertinoIcons.floppy_disk,
                                color: ConstantColor.blueBackground, size: 18.0,),
                              SizedBox(width: 10,),
                              googleSansText(text: "Save PDF", colors: ConstantColor.blueBackground, fontWeight: FontWeight.w700, size: 18.0, textAlign: TextAlign.center, softWrap: true),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => slideRightWidget(newPage: InvoicePreviewPage(), context: context),
                          style: ButtonStyle(
                            fixedSize: WidgetStateProperty.all(Size(MediaQuery.of(context).size.width, 60.0)),
                            backgroundColor: WidgetStateProperty.all(ConstantColor.blueBackground),
                            shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Platform.isAndroid
                                  ? Icons.share
                                  : CupertinoIcons.share,
                                color: Colors.white, size: 18.0,),
                              SizedBox(width: 10,),
                              googleSansText(text: "Share", colors: Colors.white, fontWeight: FontWeight.w700, size: 18.0, textAlign: TextAlign.center, softWrap: true),
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
