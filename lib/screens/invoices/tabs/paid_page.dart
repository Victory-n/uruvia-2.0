import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../widgets/custom_text.dart';

class PaidPage extends StatefulWidget {
  const PaidPage({super.key});

  @override
  State<PaidPage> createState() => _PaidPageState();
}

class _PaidPageState extends State<PaidPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
                      googleSansText(text: "Tech Corp Solutions", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                      googleSansText(text: "INV-2023-089", colors: ConstantColor.paragraphTextSecondary.withAlpha(80), fontWeight: FontWeight.normal, size: 11.0, textAlign: TextAlign.center, softWrap: true),
                    ],
                  ),
                  SizedBox(height: 8.0,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      googleSansText(text: "Amount", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.normal, size: 11.0, textAlign: TextAlign.center, softWrap: true),
                      googleSansText(text: "₦450,000", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                    ],
                  ),
                  SizedBox(height: 8.0,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      googleSansText(text: "Due", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.normal, size: 11.0, textAlign: TextAlign.center, softWrap: true),
                      googleSansText(text: "Oct 12, 2026", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.normal, size: 16.0, textAlign: TextAlign.center, softWrap: true),
                    ],
                  ),
                  SizedBox(height: 8.0,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      googleSansText(text: "Status", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.normal, size: 11.0, textAlign: TextAlign.center, softWrap: true),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.green.withAlpha(50),
                        ),
                        child: googleSansText(text: "Paid", colors: Colors.green, fontWeight: FontWeight.normal, size: 11.0, textAlign: TextAlign.center, softWrap: true),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
