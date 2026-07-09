import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:uruvia/connection/connectivity_service.dart';
import 'package:uruvia/screens/inventory/add_inventory_page.dart';
import 'package:uruvia/screens/inventory/inventory_detailed_page.dart';
import '../../constants/colors.dart';
import '../../widgets/custom_column_heading_text.dart';
import '../../widgets/custom_text.dart';

class InventoryMainPage extends StatefulWidget {
  const InventoryMainPage({super.key});

  @override
  State<InventoryMainPage> createState() => _InventoryMainPageState();
}

class _InventoryMainPageState extends State<InventoryMainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => slideUpWidget(newPage: AddInventoryPage(), context: context),
        backgroundColor: ConstantColor.blueBackground,
        child: Icon(
          Platform.isAndroid ? Icons.add : CupertinoIcons.add,
          color: Colors.white,
        ),
      ),
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
          ValueListenableBuilder<bool>(
            valueListenable: ConnectivityService.instance.isConnected,
            builder: (context, isOnline, _) {
              if (isOnline) {
                return IconButton(
                  onPressed: () {},
                  icon: Platform.isAndroid
                      ? const Icon(Icons.cloud_done_outlined, color: ConstantColor.paragraphTextPrimary)
                      : const Icon(CupertinoIcons.cloud_upload, color: ConstantColor.paragraphTextPrimary),
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(Icons.cloud_off, color: Colors.red, size: 20.0),
                      SizedBox(width: 4.0),
                      Text(
                        "Offline",
                        style: TextStyle(
                          fontFamily: "Inter",
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          scrollDirection: Axis.vertical,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
              child: columnText(
                headingText: interText(text: "Inventory Management", colors: Colors.black, fontWeight: FontWeight.w600, size: 24.0, textAlign: TextAlign.center, softWrap: true),
                subtext: googleSansText(text: "track and manage your product stock levels.", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.normal, size: 14.0, textAlign: TextAlign.center, softWrap: true),
              ),
            ),
            // Green container
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InventoryDetailedPage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'hero-image',
                      child: Container(
                        height: 324,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            image: DecorationImage(image: AssetImage("assets/img/inventory/inventory-1.png"), fit: BoxFit.cover)
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        googleSansText(text: "Smart Watch Series 5", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                        googleSansText(text: "SKU: SW-S5-BLK", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.bold, size: 14.0, textAlign: TextAlign.center, softWrap: true),
                      ],
                    ),
                    SizedBox(height: 10.0,),
                    Divider(color: ConstantColor.blueBackground,),
                    SizedBox(height: 10.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            googleSansText(text: "Current Stock", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                            googleSansText(text: "52", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 14.0, textAlign: TextAlign.center, softWrap: true),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            googleSansText(text: "Threshold: 10", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.green.shade50,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Platform.isAndroid
                                        ? Icons.check_circle_outline
                                        : CupertinoIcons.check_mark_circled,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 7.0,),
                                  googleSansText(text: "Healthy", colors: Colors.green, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.0,),

            // Out of stock
            GestureDetector(
              onTap: () => slideRightWidget(newPage: InventoryDetailedPage(), context: context),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                  border: Border.all(color: Colors.red),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 324,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          image: DecorationImage(image: AssetImage("assets/img/inventory/inventory-2.png"), fit: BoxFit.cover)
                      ),
                    ),
                    SizedBox(height: 10.0,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        googleSansText(text: "Portable BT Speaker", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                        googleSansText(text: "SKU: BTS-200X", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.bold, size: 14.0, textAlign: TextAlign.center, softWrap: true),
                      ],
                    ),
                    SizedBox(height: 10.0,),
                    Divider(color: ConstantColor.blueBackground,),
                    SizedBox(height: 10.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            googleSansText(text: "Current Stock", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                            googleSansText(text: "2", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 14.0, textAlign: TextAlign.center, softWrap: true),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            googleSansText(text: "Threshold: 25", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.red.shade50,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Platform.isAndroid
                                        ? Icons.warning_amber
                                        : CupertinoIcons.exclamationmark_triangle,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 7.0,),
                                  googleSansText(text: "Critical", colors: Colors.red, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.0,),

            // Green container
            GestureDetector(
              onTap: () => slideRightWidget(newPage: InventoryDetailedPage(), context: context),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 324,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          image: DecorationImage(image: AssetImage("assets/img/inventory/inventory-1.png"), fit: BoxFit.cover)
                      ),
                    ),
                    SizedBox(height: 10.0,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        googleSansText(text: "Smart Watch Series 5", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                        googleSansText(text: "SKU: SW-S5-BLK", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.bold, size: 14.0, textAlign: TextAlign.center, softWrap: true),
                      ],
                    ),
                    SizedBox(height: 10.0,),
                    Divider(color: ConstantColor.blueBackground,),
                    SizedBox(height: 10.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            googleSansText(text: "Current Stock", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                            googleSansText(text: "52", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 14.0, textAlign: TextAlign.center, softWrap: true),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            googleSansText(text: "Threshold: 10", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.green.shade50,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Platform.isAndroid
                                        ? Icons.check_circle_outline
                                        : CupertinoIcons.check_mark_circled,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 7.0,),
                                  googleSansText(text: "Healthy", colors: Colors.green, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.0,),

            // Out of stock
            GestureDetector(
              onTap: () => slideRightWidget(newPage: InventoryDetailedPage(), context: context),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                  border: Border.all(color: Colors.red),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 324,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          image: DecorationImage(image: AssetImage("assets/img/inventory/inventory-2.png"), fit: BoxFit.cover)
                      ),
                    ),
                    SizedBox(height: 10.0,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        googleSansText(text: "Portable BT Speaker", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                        googleSansText(text: "SKU: BTS-200X", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.bold, size: 14.0, textAlign: TextAlign.center, softWrap: true),
                      ],
                    ),
                    SizedBox(height: 10.0,),
                    Divider(color: ConstantColor.blueBackground,),
                    SizedBox(height: 10.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            googleSansText(text: "Current Stock", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                            googleSansText(text: "2", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 14.0, textAlign: TextAlign.center, softWrap: true),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            googleSansText(text: "Threshold: 25", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.red.shade50,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Platform.isAndroid
                                        ? Icons.warning_amber
                                        : CupertinoIcons.exclamationmark_triangle,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 7.0,),
                                  googleSansText(text: "Critical", colors: Colors.red, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
