import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/screens/default%20screens/error_screen.dart';
import 'package:uruvia/screens/default%20screens/success_screen.dart';

import '../../widgets/custom_text.dart';

class InventoryDetailedPage extends StatefulWidget {
  const InventoryDetailedPage({super.key});

  @override
  State<InventoryDetailedPage> createState() => _InventoryDetailedPageState();
}

class _InventoryDetailedPageState extends State<InventoryDetailedPage> {

  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsetsGeometry.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              children: [
                Hero(
                  tag: 'hero-image',
                  child: Container(
                    height: 300,
                    // width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: DecorationImage(image: AssetImage("assets/img/inventory/inventory-1.png"), fit: BoxFit.cover)
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  padding: const EdgeInsets.all(24.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: BoxBorder.all(color: ConstantColor.paragraphTextSecondary.withAlpha(50)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      googleSansText(text: "Product Information", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                      Divider(color: ConstantColor.paragraphTextSecondary.withAlpha(50),),
                      googleSansText(text: "SKU Code", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.bold, size: 11.0, textAlign: TextAlign.center, softWrap: true),
                      SizedBox(height: 5.0),
                      Row(
                        children: [
                          googleSansText(text: "WH-1002A", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                          SizedBox(width: 7),
                          Icon(Platform.isAndroid
                              ? Icons.copy_rounded
                              : CupertinoIcons.doc_on_doc,
                              color: ConstantColor.blueBackground,
                          size: 16,),
                        ],
                      ),
                      SizedBox(height: 16),
                      googleSansText(text: "Retail Price", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.bold, size: 11.0, textAlign: TextAlign.center, softWrap: true),
                      SizedBox(height: 7),
                      googleSansText(text: "₦45,000", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                      SizedBox(height: 16.0),
                      Divider(color: ConstantColor.paragraphTextSecondary.withAlpha(50),),
                      SizedBox(height: 16.0),
                      googleSansText(text: "Supplier", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                    ],
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  padding: const EdgeInsets.all(24.0),
                  height: 174,
                  // width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                    color: Color(0xFF131B2E),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              googleSansText(text: "Current Stock", colors: Colors.white, fontWeight: FontWeight.bold, size: 18.0, textAlign: TextAlign.center, softWrap: true),
                              googleSansText(text: "Warehouse A", colors: Colors.white, fontWeight: FontWeight.bold, size: 13.0, textAlign: TextAlign.center, softWrap: true),
                            ],
                          ),
                          Icon(Platform.isAndroid
                              ? Icons.inventory_outlined
                              : CupertinoIcons.archivebox,
                          color: Colors.green),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          googleSansText(text: "145", colors: Colors.white, fontWeight: FontWeight.bold, size: 48.0, textAlign: TextAlign.center, softWrap: true),
                          ColoredBox(
                            color: Colors.white,
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Platform.isAndroid ? Icons.add : CupertinoIcons.add,
                                  ),
                                ),
                                const VerticalDivider(
                                  color: Colors.red,
                                  thickness: 2,
                                  width: 20,
                                  indent: 10,
                                  endIndent: 10,
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Platform.isAndroid ? Icons.remove_rounded : CupertinoIcons.minus,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  padding: const EdgeInsets.all(24.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: BoxBorder.all(color: ConstantColor.paragraphTextSecondary.withAlpha(50)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Platform.isAndroid
                              ? Icons.notifications_none
                              : CupertinoIcons.bell,
                            color: ConstantColor.paragraphTextPrimary,
                            size: 16,),
                          SizedBox(width: 7),
                          googleSansText(text: "Inventory Alert", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                        ],
                      ),
                      SizedBox(height: 10),
                      Divider(color: ConstantColor.paragraphTextSecondary.withAlpha(50),),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              googleSansText(text: "Low Stock Warning", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                              googleSansText(text: "Notify when quantity drops below:", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 13.0, textAlign: TextAlign.center, softWrap: true),
                            ],
                          ),
                          Switch.adaptive(
                            value: isSwitched,
                            onChanged: (bool value) {
                              setState(() {
                                isSwitched = value;
                              });
                            },
                            activeThumbColor: Colors.white,
                            activeTrackColor: ConstantColor.blueBackground,
                            inactiveThumbColor: ConstantColor.paragraphTextSecondary,
                            inactiveTrackColor: ConstantColor.paragraphTextSecondary.withAlpha(50),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        children: [
                          Container(
                            width: 96,
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: TextField(
                              readOnly: isSwitched,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          googleSansText(text: "Units", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  padding: const EdgeInsets.all(24.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: BoxBorder.all(color: ConstantColor.paragraphTextSecondary.withAlpha(50)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      googleSansText(text: "ACTIONS", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                      SizedBox(height: 16),
                      FittedBox(
                        child: ElevatedButton(
                          onPressed: () => slideUpWidget(newPage: SuccessScreen(), context: context),
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
                          onPressed: () => slideUpWidget(newPage: ErrorScreen(), context: context),
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
