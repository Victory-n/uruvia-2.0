import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/widgets/custom_text.dart';
import 'package:uruvia/classes/custom_snackbar.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  String _selectedCategory = 'General Inquiry';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'General Inquiry',
    'Account / Billing',
    'App Bug / Crash',
    'Feature Request',
    'Other / Complaints',
  ];

  // Contact Info Constants
  static const String supportEmail = 'support@uruvia.com';
  static const String mainPhone = '+2348123456789';
  static const String mainPhoneDisplay = '+234 812 345 6789';
  static const String whatsappPhone = '+2349012345678';
  static const String whatsappPhoneDisplay = '+234 901 234 5678';

  @override
  void initState() {
    super.initState();
    _prepopulateUserInfo();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _prepopulateUserInfo() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final userMetadata = user.userMetadata;
      final String firstName = userMetadata?['first_name'] ?? '';
      final String lastName = userMetadata?['last_name'] ?? '';
      final String fullName = '$firstName $lastName'.trim();

      _nameController.text = fullName;
      _emailController.text = user.email ?? '';
    }
  }

  Future<void> _launchContactUrl(
    String urlString,
    String copyText,
    String typeName,
  ) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch URL';
      }
    } catch (e) {
      // Fallback: Copy to clipboard
      await Clipboard.setData(ClipboardData(text: copyText));
      if (mounted) {
        CustomSnackbar.showSuccess(context, "$typeName copied to clipboard!");
      }
    }
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Simulate sending complaint / storing in DB or email mock
    await Future.delayed(const Duration(seconds: 15 > 0 ? 2 : 1));

    if (!mounted) return;

    setState(() => _isSubmitting = false);
    _messageController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Row(
          children: [
            const Icon(
              CupertinoIcons.checkmark_circle_fill,
              color: Colors.green,
              size: 28.0,
            ),
            const SizedBox(width: 8.0),
            googleSansText(
              text: "Success",
              colors: ConstantColor.headingTextPrimary,
              fontWeight: FontWeight.bold,
              size: 18.0,
            ),
          ],
        ),
        content: googleSansText(
          text:
              "Your complaint has been submitted successfully. Our support team will review it and get back to you shortly.",
          colors: ConstantColor.paragraphTextPrimary,
          fontWeight: FontWeight.normal,
          size: 14.5,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: ConstantColor.blueBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              elevation: 0.0,
            ),
            child: googleSansText(
              text: "OK",
              colors: Colors.white,
              fontWeight: FontWeight.bold,
              size: 14.0,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        backgroundColor: const Color(0xFFF9FAFC),
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
          text: "Support & Help",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 20.0,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Beautiful Header card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [ConstantColor.blueBackground, Color(0xFF003F8A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: ConstantColor.blueBackground.withOpacity(0.2),
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
                        const Icon(
                          CupertinoIcons.question_circle_fill,
                          color: Colors.white,
                          size: 32.0,
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: interText(
                            text: "How can we help you?",
                            colors: Colors.white,
                            fontWeight: FontWeight.bold,
                            size: 22.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    googleSansText(
                      text:
                          "Have a question, feedback, or a complaint? Reach out to our dedicated support channels or send us a direct message below.",
                      colors: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.normal,
                      size: 14.0,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // 2. Contact Channels Heading
              googleSansText(
                text: "DIRECT CHANNELS",
                colors: ConstantColor.paragraphTextSecondary,
                fontWeight: FontWeight.bold,
                size: 11.5,
              ),
              const SizedBox(height: 10.0),

              // Contact Cards row/list
              _buildContactItem(
                icon: CupertinoIcons.chat_bubble_2_fill,
                iconColor: Colors.green,
                title: "WhatsApp Chat",
                subtitle: whatsappPhoneDisplay,
                buttonText: "Chat Now",
                onTap: () => _launchContactUrl(
                  'https://wa.me/${whatsappPhone.replaceAll('+', '')}?text=Hello%20Uruvia%20Support!',
                  whatsappPhoneDisplay,
                  "WhatsApp link",
                ),
              ),
              const SizedBox(height: 10.0),
              _buildContactItem(
                icon: CupertinoIcons.phone_fill,
                iconColor: ConstantColor.blueBackground,
                title: "Phone Call",
                subtitle: mainPhoneDisplay,
                buttonText: "Call Us",
                onTap: () => _launchContactUrl(
                  'tel:$mainPhone',
                  mainPhoneDisplay,
                  "Phone number",
                ),
              ),
              const SizedBox(height: 10.0),
              _buildContactItem(
                icon: CupertinoIcons.mail_solid,
                iconColor: Colors.redAccent,
                title: "Email Address",
                subtitle: supportEmail,
                buttonText: "Send Email",
                onTap: () => _launchContactUrl(
                  'mailto:$supportEmail?subject=Uruvia%20Support%20Request',
                  supportEmail,
                  "Email address",
                ),
              ),

              const SizedBox(height: 24.0),

              // 3. Complaint Form Heading
              googleSansText(
                text: "SUBMIT A COMPLAINT",
                colors: ConstantColor.paragraphTextSecondary,
                fontWeight: FontWeight.bold,
                size: 11.5,
              ),
              const SizedBox(height: 10.0),

              // Complaint Form Container
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 10.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      _buildTextField(
                        controller: _nameController,
                        label: "Full Name",
                        hint: "Your name",
                        icon: CupertinoIcons.person_fill,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? "Please enter your name"
                            : null,
                      ),
                      const SizedBox(height: 14.0),

                      // Email
                      _buildTextField(
                        controller: _emailController,
                        label: "Email Address",
                        hint: "Your email address",
                        icon: CupertinoIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty)
                            return "Please enter your email";
                          final emailRegExp = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );
                          if (!emailRegExp.hasMatch(value.trim()))
                            return "Please enter a valid email address";
                          return null;
                        },
                      ),
                      const SizedBox(height: 14.0),

                      // Category Dropdown
                      googleSansText(
                        text: "Complaint Category",
                        colors: ConstantColor.paragraphTextSecondary,
                        fontWeight: FontWeight.bold,
                        size: 11.0,
                      ),
                      const SizedBox(height: 6.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8FA),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: const Color(0xFFE8E9EB)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            icon: const Icon(
                              CupertinoIcons.chevron_down,
                              size: 16.0,
                              color: ConstantColor.paragraphTextSecondary,
                            ),
                            style: const TextStyle(
                              fontFamily: "googleSans",
                              fontSize: 14.5,
                              color: ConstantColor.headingTextPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            items: _categories.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedCategory = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14.0),

                      // Message
                      _buildTextField(
                        controller: _messageController,
                        label: "Message / Complaint Details",
                        hint:
                            "Please describe your issue or suggestion in detail...",
                        icon: CupertinoIcons.chat_bubble_text_fill,
                        maxLines: 5,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? "Please enter your message details"
                            : null,
                      ),
                      const SizedBox(height: 20.0),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50.0,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitComplaint,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ConstantColor.blueBackground,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: ConstantColor
                                .blueBackground
                                .withOpacity(0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            elevation: 0.0,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20.0,
                                  width: 20.0,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : googleSansText(
                                  text: "Submit Complaint",
                                  colors: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  size: 15.0,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.1),
            radius: 20.0,
            child: Icon(icon, color: iconColor, size: 18.0),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                googleSansText(
                  text: title,
                  colors: ConstantColor.headingTextPrimary,
                  fontWeight: FontWeight.bold,
                  size: 14.5,
                ),
                const SizedBox(height: 2.0),
                googleSansText(
                  text: subtitle,
                  colors: ConstantColor.paragraphTextSecondary,
                  fontWeight: FontWeight.normal,
                  size: 13.0,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF0F5FA),
              foregroundColor: ConstantColor.blueBackground,
              elevation: 0.0,
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: googleSansText(
              text: buttonText,
              colors: ConstantColor.blueBackground,
              fontWeight: FontWeight.bold,
              size: 12.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    FormFieldValidator<String>? validator,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: const Color(0xFFE8E9EB)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(
          fontFamily: "googleSans",
          fontSize: 14.5,
          color: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontFamily: "googleSans",
            color: ConstantColor.paragraphTextSecondary,
            fontSize: 13.0,
          ),
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: "googleSans",
            color: Color(0xFFBBBBBB),
            fontSize: 13.5,
          ),
          prefixIcon: Icon(
            icon,
            color: ConstantColor.paragraphTextSecondary,
            size: 18.0,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 6.0),
        ),
      ),
    );
  }
}
