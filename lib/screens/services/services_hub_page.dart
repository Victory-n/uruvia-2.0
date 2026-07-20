import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/widgets/custom_text.dart';
import 'package:uruvia/screens/services/cac_registration_form.dart';
import 'package:uruvia/screens/services/logistics_request_form.dart';
import 'package:uruvia/classes/custom_snackbar.dart';

class ServicesHubPage extends StatefulWidget {
  const ServicesHubPage({super.key});

  @override
  State<ServicesHubPage> createState() => _ServicesHubPageState();
}

class _ServicesHubPageState extends State<ServicesHubPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        leading: Navigator.canPop(context)
            ? null
            : IconButton(
                icon: const Icon(
                  CupertinoIcons.bars,
                  color: ConstantColor.headingTextPrimary,
                ),
                onPressed: () => Scaffold.maybeOf(context)?.openDrawer(),
              ),
        title: googleSansText(
          text: "Uruvia Hub & Services",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 19.0,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      ConstantColor.headingTextPrimary,
                      ConstantColor.blueBackground,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.briefcase_fill,
                            color: Colors.amber,
                            size: 24.0,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        googleSansText(
                          text: "Professional Business Services",
                          colors: Colors.white,
                          fontWeight: FontWeight.bold,
                          size: 16.0,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    googleSansText(
                      text:
                          "Let Uruvia handle your business registration, logistics dispatch, and compliance so you can focus on growing.",
                      colors: Colors.white70,
                      fontWeight: FontWeight.normal,
                      size: 13.0,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              googleSansText(
                text: "Available Services",
                colors: ConstantColor.headingTextPrimary,
                fontWeight: FontWeight.bold,
                size: 17.0,
              ),
              const SizedBox(height: 14.0),

              // Service 1: Uruvia Special SME Growth Loan (Coming Soon)
              _buildServiceCard(
                context: context,
                icon: CupertinoIcons.money_dollar_circle_fill,
                iconBgColor: const Color(0xFFE8F5E9),
                iconColor: const Color(0xFF2E7D32),
                title: "Uruvia SME Growth Loan",
                description:
                    "Exclusive low-interest business loans powered by Uruvia to help upscale your small business, restock inventory, or expand daily operations.",
                priceTag: "Uruvia Special • Low Interest",
                buttonLabel: "Apply for Loan",
                isComingSoon: true,
                onTap: () {
                  CustomSnackbar.showNormal(
                    context,
                    "Uruvia SME Growth Loan service is coming soon!",
                  );
                },
              ),
              const SizedBox(height: 16.0),

              // Service 2: CAC Business Registration
              _buildServiceCard(
                context: context,
                icon: CupertinoIcons.doc_checkmark_fill,
                iconBgColor: const Color(0xFFEFF6FF),
                iconColor: ConstantColor.blueBackground,
                title: "CAC Business Name Registration",
                description:
                    "Register your sole proprietorship, enterprise, or company with CAC Nigeria. Includes official certificate & status tracking.",
                priceTag: "₦25,000 (~\$30)",
                buttonLabel: "Register Business",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CacRegistrationForm(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16.0),

              // Service 3: Logistics & Parcel Transmission
              _buildServiceCard(
                context: context,
                icon: CupertinoIcons.alt,
                iconBgColor: const Color(0xFFFEF3C7),
                iconColor: Colors.amber.shade900,
                title: "Logistics & Goods Transmission",
                description:
                    "Dispatch parcels, invoices, or inventory to your clients safely via onboarded logistics partners across Nigeria and West Africa.",
                priceTag: "Quote on Request",
                buttonLabel: "Dispatch Parcel",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LogisticsRequestForm(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16.0),

              // Service 4: Tax ID (TIN) - Coming Soon
              _buildServiceCard(
                context: context,
                icon: CupertinoIcons.building_2_fill,
                iconBgColor: const Color(0xFFF1F5F9),
                iconColor: Colors.grey.shade700,
                title: "Tax Identification Number (TIN)",
                description:
                    "Obtain your official Business Tax ID and FIRS compliance documentation seamlessly.",
                priceTag: "Coming Soon",
                buttonLabel: "Notify Me",
                isComingSoon: true,
                onTap: () {
                  CustomSnackbar.showNormal(
                    context,
                    "TIN registration service launching soon!",
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String description,
    required String priceTag,
    required String buttonLabel,
    required VoidCallback onTap,
    bool isComingSoon = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(icon, color: iconColor, size: 22.0),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    googleSansText(
                      text: title,
                      colors: ConstantColor.headingTextPrimary,
                      fontWeight: FontWeight.bold,
                      size: 15.0,
                    ),
                    const SizedBox(height: 2.0),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 2.0,
                      ),
                      decoration: BoxDecoration(
                        color: isComingSoon
                            ? Colors.grey.shade100
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: googleSansText(
                        text: priceTag,
                        colors: isComingSoon
                            ? Colors.grey.shade700
                            : ConstantColor.blueBackground,
                        fontWeight: FontWeight.bold,
                        size: 11.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          googleSansText(
            text: description,
            colors: ConstantColor.paragraphTextPrimary,
            fontWeight: FontWeight.normal,
            size: 13.0,
          ),
          const SizedBox(height: 16.0),
          SizedBox(
            width: double.infinity,
            height: 44.0,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isComingSoon
                    ? Colors.grey.shade300
                    : ConstantColor.blueBackground,
                elevation: 0.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: googleSansText(
                text: buttonLabel,
                colors: isComingSoon ? Colors.grey.shade700 : Colors.white,
                fontWeight: FontWeight.bold,
                size: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
