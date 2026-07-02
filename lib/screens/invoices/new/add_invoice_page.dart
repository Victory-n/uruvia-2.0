import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:uruvia/screens/invoices/new/invoice_preview_page.dart';
import '../../../constants/colors.dart';
import '../../../widgets/custom_text.dart';

class AddInvoicePage extends StatefulWidget {
  const AddInvoicePage({super.key});

  @override
  State<AddInvoicePage> createState() => _AddInvoicePageState();
}

class _AddInvoicePageState extends State<AddInvoicePage> {

  List<Map<String, dynamic>> items = [
    {
      "controller": TextEditingController(text: "Consulting Services"),
      "amount": 0,
      "price": 3200,
    }
  ];

  int get subtotal => items.fold(0, (sum, item) => sum + (item['amount'] * item['price'] as int));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        backgroundColor: Colors.white,
        title: interText(text: "New Invoice", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 20.0, textAlign: TextAlign.center, softWrap: true),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Platform.isAndroid ? Icon(Icons.cloud_done_outlined, color: ConstantColor.paragraphTextPrimary,) : Icon(CupertinoIcons.cloud_upload, color: ConstantColor.paragraphTextPrimary,),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: ConstantColor.paragraphTextSecondary.withAlpha(50)),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      googleSansText(text: "CUSTOMER DETAILS", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 12.0, textAlign: TextAlign.center, softWrap: true),
                      SizedBox(height: 12.0,),
                      SearchBar(
                        hintText: "Pick from directory",
                        hintStyle: WidgetStatePropertyAll(TextStyle(fontFamily: "googleSans", color: ConstantColor.paragraphTextSecondary)),
                        backgroundColor: WidgetStatePropertyAll(ConstantColor.paragraphTextSecondary.withAlpha(30)),
                        elevation: WidgetStatePropertyAll(0.0),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
                        side: WidgetStateProperty.all(BorderSide(color: ConstantColor.paragraphTextSecondary.withAlpha(50),)),
                      ),
                      SizedBox(height: 12.0,),
                      Center(
                        child: googleSansText(text: "OR", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 12.0, textAlign: TextAlign.center, softWrap: true),
                      ),
                      SizedBox(height: 12.0,),
                      FittedBox(
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
                                  ? Icons.person_add_alt
                                  : CupertinoIcons.person_badge_plus,
                                color: ConstantColor.blueBackground, size: 18.0,),
                              SizedBox(width: 10,),
                              googleSansText(text: "New Customer", colors: ConstantColor.blueBackground, fontWeight: FontWeight.bold, size: 18.0, textAlign: TextAlign.center, softWrap: true),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.0,),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: ConstantColor.paragraphTextSecondary.withAlpha(50)),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
                          color: Color(0xFFEFF4FF),
                        ),
                        child: Padding(
                          padding: const EdgeInsetsGeometry.all(12.0),
                          child: googleSansText(text: "LINE ITEMS", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.w700, size: 12.0, textAlign: TextAlign.left, softWrap: true),
                        ),
                      ),
                      ...items.map((item) => Container(
                        height: 150,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          border: Border.symmetric(horizontal: BorderSide(color: ConstantColor.paragraphTextSecondary.withAlpha(50))),
                          color: Colors.transparent,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: item['controller'],
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        items.remove(item);
                                      });
                                    },
                                    icon: Icon(CupertinoIcons.xmark,
                                      color: ConstantColor.paragraphTextSecondary.withAlpha(70),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            if (item['amount'] > 0) {
                                              item['amount']--;
                                            }
                                          });
                                        },
                                        icon: Icon(Platform.isAndroid ? Icons.remove_rounded : CupertinoIcons.minus, color: ConstantColor.paragraphTextSecondary,),
                                      ),
                                      googleSansText(text: "${item['amount']}", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.w700, size: 16.0, textAlign: TextAlign.left, softWrap: true),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            item['amount']++;
                                          });
                                        },
                                        icon: Icon(Platform.isAndroid ? Icons.add : CupertinoIcons.add, color: ConstantColor.paragraphTextSecondary,),
                                      ),
                                    ],
                                  ),
                                  googleSansText(text: "₦${item['price']}", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.w700, size: 16.0, textAlign: TextAlign.left, softWrap: true),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )).toList(),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              items.add({
                                "controller": TextEditingController(text: "New Item"),
                                "amount": 0,
                                "price": 3200,
                              });
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Platform.isAndroid ? Icons.add_circle_outline : CupertinoIcons.add_circled, color: ConstantColor.blueBackground,),
                              SizedBox(width: 10.0,),
                              googleSansText(text: "Add new item", colors: ConstantColor.blueBackground, fontWeight: FontWeight.bold, size: 18.0, textAlign: TextAlign.center, softWrap: true),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.0,),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: ConstantColor.paragraphTextSecondary.withAlpha(50)),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          googleSansText(text: "Subtotal", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.normal, size: 18.0, textAlign: TextAlign.center, softWrap: true),
                          googleSansText(text: "₦$subtotal", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 18.0, textAlign: TextAlign.center, softWrap: true),
                        ],
                      ),
                      SizedBox(height: 10.0,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          googleSansText(text: "Tax (0%)", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.normal, size: 18.0, textAlign: TextAlign.center, softWrap: true),
                          googleSansText(text: "₦0.00", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 18.0, textAlign: TextAlign.center, softWrap: true),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          googleSansText(text: "Total", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 18.0, textAlign: TextAlign.center, softWrap: true),
                          googleSansText(text: "₦$subtotal", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 30.0, textAlign: TextAlign.center, softWrap: true),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.0,),
                FittedBox(
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
                        googleSansText(text: "Save as Draft (Offline)", colors: ConstantColor.blueBackground, fontWeight: FontWeight.w700, size: 18.0, textAlign: TextAlign.center, softWrap: true),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                FittedBox(
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
                            ? Icons.refresh
                            : CupertinoIcons.refresh,
                          color: Colors.white, size: 18.0,),
                        SizedBox(width: 10,),
                        googleSansText(text: "Preview", colors: Colors.white, fontWeight: FontWeight.w700, size: 18.0, textAlign: TextAlign.center, softWrap: true),
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
