import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../widgets/app_text.dart';
import '../models/ajo_group.dart';

class AjoJoinSheet extends StatefulWidget {
  final AjoGroup group;
  final Function(String name, String bankName, String accountNumber, String payoutMonth) onJoined;

  const AjoJoinSheet({
    super.key,
    required this.group,
    required this.onJoined,
  });

  static Future<void> show(
    BuildContext context, {
    required AjoGroup group,
    required Function(String name, String bankName, String accountNumber, String payoutMonth) onJoined,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AjoJoinSheet(group: group, onJoined: onJoined),
    );
  }

  @override
  State<AjoJoinSheet> createState() => _AjoJoinSheetState();
}

class _AjoJoinSheetState extends State<AjoJoinSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _accountController = TextEditingController();

  String _selectedBank = 'Guaranty Trust Bank';
  final String _preferredMonth = 'Next Available';

  final List<String> _banks = const [
    'Guaranty Trust Bank',
    'Access Bank',
    'Zenith Bank',
    'Kuda Microfinance Bank',
    'United Bank for Africa',
    'First Bank of Nigeria',
    'OPay',
    'PalmPay',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onJoined(
        _nameController.text.trim(),
        _selectedBank,
        _accountController.text.trim(),
        _preferredMonth,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText.subtitle(
                    'Join Ajo Savings Pool',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const FaIcon(
                      FontAwesomeIcons.xmark,
                      color: Color(0xFF64748B),
                      size: 16,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.handshakeAngle,
                      color: Color(0xFF2563EB),
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.custom(
                            widget.group.title,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          AppText.paragraph(
                            'Contribution: ${currencyFormatter.format(widget.group.contributionPerMember)} / ${widget.group.frequency.toLowerCase()}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF3B82F6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const AppText.paragraph(
                'Enter your details for receiving your lump-sum payout when it is your turn:',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Your Full Name',
                  hintText: 'e.g. John Doe',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: FaIcon(FontAwesomeIcons.user, size: 14),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedBank,
                decoration: const InputDecoration(
                  labelText: 'Payout Bank',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: FaIcon(FontAwesomeIcons.buildingColumns, size: 14),
                  ),
                ),
                items: _banks
                    .map((bank) => DropdownMenuItem(
                          value: bank,
                          child: AppText.paragraph(bank, style: const TextStyle(fontSize: 13)),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedBank = val);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _accountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Account Number',
                  hintText: '10-digit NUBAN account number',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: FaIcon(FontAwesomeIcons.hashtag, size: 14),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Enter account number';
                  }
                  if (val.trim().length < 10) {
                    return 'Enter a valid 10-digit number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0060E6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const AppText.button(
                    'Accept Invite & Join Pool',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
