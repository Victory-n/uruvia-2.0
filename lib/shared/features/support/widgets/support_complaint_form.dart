import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../theme/individual/app_theme.dart';
import '../../../../theme/business/business_theme.dart';

class SupportComplaintForm extends StatefulWidget {
  final Function(String name, String email, String category, String message) onSubmit;
  final bool isBusiness;

  const SupportComplaintForm({
    super.key,
    required this.onSubmit,
    this.isBusiness = false,
  });

  @override
  State<SupportComplaintForm> createState() => _SupportComplaintFormState();
}

class _SupportComplaintFormState extends State<SupportComplaintForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final _messageController = TextEditingController();

  late String _selectedCategory;

  List<String> get _categories => widget.isBusiness
      ? const [
          'POS & Terminal Operations',
          'Inventory & Stock Discrepancy',
          'Invoicing & Customer Billing',
          'Employee & Access Permissions',
          'Payout & Settlement Delay',
          'App Bug / System Glitch',
          'General Business Inquiries',
        ]
      : const [
          'App Bug / Crash',
          'Transaction & Budget Issue',
          'Wallet Transfer Failure',
          'Account Access & Security',
          'Event & Savings Issue',
          'Feature Request & Feedback',
          'General Inquiries',
        ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.isBusiness ? 'Acme Store' : 'John Doe',
    );
    _emailController = TextEditingController(
      text: widget.isBusiness ? 'contact@acmestore.com' : 'example@gmail.com',
    );
    _selectedCategory = widget.isBusiness
        ? 'POS & Terminal Operations'
        : 'App Bug / Crash';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _showCategoryPicker() {
    final accentColor = widget.isBusiness
        ? BusinessTheme.primaryAmber
        : AppTheme.accentBlue;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AppText.subtitle(
                    widget.isBusiness
                        ? 'Select Inquiry Topic'
                        : 'Select Complaint Category',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: widget.isBusiness
                          ? BusinessTheme.textDark
                          : AppTheme.textDark,
                    ),
                  ),
                ),
              ),
              const Divider(color: Color(0xFFF1F5F9)),
              ..._categories.map((category) {
                final isSelected = category == _selectedCategory;
                return ListTile(
                  title: AppText.paragraph(
                    category,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? accentColor
                          : (widget.isBusiness
                              ? BusinessTheme.textDark
                              : AppTheme.textDark),
                    ),
                  ),
                  trailing: isSelected
                      ? FaIcon(
                          FontAwesomeIcons.check,
                          color: accentColor,
                          size: 15,
                        )
                      : null,
                  onTap: () {
                    setState(() => _selectedCategory = category);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final message = _messageController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: widget.isBusiness
              ? BusinessTheme.charcoal
              : AppTheme.sleekBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: const AppText.custom(
            'Please fill in your name and email.',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      );
      return;
    }

    widget.onSubmit(name, email, _selectedCategory, message);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isBiz = widget.isBusiness;

    final cardBorder = isBiz
        ? BusinessTheme.textMuted.withValues(alpha: 0.15)
        : const Color(0xFFF1F5F9);

    final fieldBg = isBiz
        ? const Color(0xFFFAF9F7)
        : const Color(0xFFF8FAFC);

    final fieldBorder = isBiz
        ? const Color(0xFFE7E5E4)
        : const Color(0xFFE2E8F0);

    final labelColor = isBiz
        ? BusinessTheme.textMuted
        : AppTheme.textMuted;

    final textColor = isBiz
        ? BusinessTheme.textDark
        : AppTheme.textDark;

    final buttonBg = isBiz
        ? BusinessTheme.charcoal
        : AppTheme.sleekBlue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cardBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name Field
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            decoration: BoxDecoration(
              color: fieldBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: fieldBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.custom(
                  isBiz ? 'Business / Contact Name' : 'Full Name',
                  style: TextStyle(
                    fontSize: 11,
                    color: labelColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    FaIcon(
                      isBiz ? FontAwesomeIcons.building : FontAwesomeIcons.solidUser,
                      size: 14,
                      color: labelColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Email Field
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            decoration: BoxDecoration(
              color: fieldBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: fieldBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.custom(
                  isBiz ? 'Business Email Address' : 'Email Address',
                  style: TextStyle(
                    fontSize: 11,
                    color: labelColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.envelope,
                      size: 14,
                      color: labelColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Category Field
          AppText.custom(
            isBiz ? 'Inquiry Topic' : 'Complaint Category',
            style: TextStyle(
              fontSize: 12,
              color: labelColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: _showCategoryPicker,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: fieldBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: fieldBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AppText.custom(
                      _selectedCategory,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                  FaIcon(
                    FontAwesomeIcons.chevronDown,
                    size: 13,
                    color: labelColor,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Message Field
          AppText.custom(
            'Message (Optional)',
            style: TextStyle(
              fontSize: 12,
              color: labelColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: fieldBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: fieldBorder),
            ),
            child: TextField(
              controller: _messageController,
              minLines: 3,
              maxLines: 5,
              style: TextStyle(
                fontSize: 13,
                color: textColor,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: isBiz
                    ? 'Describe your merchant issue or account request...'
                    : 'Describe your issue or feedback in detail...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: labelColor.withValues(alpha: 0.7),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBg,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: AppText.button(
                isBiz ? 'Submit Request' : 'Submit Complaint',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
