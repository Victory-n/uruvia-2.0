import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/individual/sidebar.dart';
import 'package:uruvia/shared_features/wallet/models/wallet_account_type.dart';
import 'package:uruvia/shared_features/wallet/virtual_card_widget.dart';
import 'package:uruvia/widgets/custom_text.dart';

class WalletPage extends StatefulWidget {
  final WalletAccountType accountType;
  final String userName;
  final String accountNumber;
  final String bankName;

  const WalletPage({
    super.key,
    this.accountType = WalletAccountType.individual,
    this.userName = "Alex User",
    this.accountNumber = "8123456789",
    this.bankName = "Uruvia MFB",
  });

  @override
  State<WalletPage> createState() => _WalletPageState();
}

// Convenient alias for Individual account imports
typedef IndividualWalletPage = WalletPage;

class _WalletPageState extends State<WalletPage> {
  bool _showCVV = false;
  bool _isCardFrozen = false;
  int _selectedFilterIndex = 0;

  late final List<Map<String, dynamic>> _allTransactions;

  @override
  void initState() {
    super.initState();

    _allTransactions = widget.accountType.isBusiness
        ? const [
            {
              "title": "Client Payout - Web Project",
              "subtitle": "Apex Tech Solutions Invoice #104",
              "amount": "+₦350,000.00",
              "date": "Today, 11:20 AM",
              "type": "inflow",
              "icon": Icons.laptop_mac_rounded,
              "color": Colors.green,
            },
            {
              "title": "Adobe Creative Cloud",
              "subtitle": "Software Suite Subscription",
              "amount": "-₦28,500.00",
              "date": "Yesterday, 04:45 PM",
              "type": "outflow",
              "icon": Icons.credit_card_rounded,
              "color": Colors.redAccent,
            },
            {
              "title": "Video Gear Rental",
              "subtitle": "Camera & Lens Rental Expense",
              "amount": "-₦45,000.00",
              "date": "04 Aug 2026",
              "type": "outflow",
              "icon": Icons.videocam_outlined,
              "color": Colors.orange,
            },
            {
              "title": "Photography Milestone Payout",
              "subtitle": "Brand Shoot Project Deposit",
              "amount": "+₦120,000.00",
              "date": "02 Aug 2026",
              "type": "inflow",
              "icon": Icons.camera_alt_outlined,
              "color": Colors.green,
            },
          ]
        : const [
            {
              "title": "Salary Deposit",
              "subtitle": "Monthly Salary Transfer",
              "amount": "+₦180,000.00",
              "date": "Today, 09:30 AM",
              "type": "inflow",
              "icon": Icons.arrow_downward_rounded,
              "color": Colors.green,
            },
            {
              "title": "Netflix Subscription",
              "subtitle": "Virtual Card Payment",
              "amount": "-₦4,500.00",
              "date": "Yesterday, 08:15 PM",
              "type": "outflow",
              "icon": Icons.credit_card_rounded,
              "color": Colors.redAccent,
            },
            {
              "title": "Electricity Bill Payment",
              "subtitle": "Utility Expense",
              "amount": "-₦12,000.00",
              "date": "05 Aug 2026",
              "type": "outflow",
              "icon": Icons.bolt_rounded,
              "color": Colors.orange,
            },
            {
              "title": "Fund Transfer",
              "subtitle": "From GTBank Account",
              "amount": "+₦50,000.00",
              "date": "03 Aug 2026",
              "type": "inflow",
              "icon": Icons.add_circle_outline_rounded,
              "color": Colors.green,
            },
          ];
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$label copied to clipboard"),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBusiness = widget.accountType.isBusiness;

    return Scaffold(
      backgroundColor: ConstantColor.lightBackground,
      drawer: const IndividualDrawer(selectedIndex: 1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: Builder(
          builder: (scaffoldContext) => IconButton(
            icon: const Icon(
              Icons.menu,
              color: ConstantColor.headingTextPrimary,
            ),
            onPressed: () {
              Scaffold.of(scaffoldContext).openDrawer();
            },
          ),
        ),
        title: googleSansText(
          text: isBusiness
              ? "Business Wallet & Payouts"
              : "Wallet & Virtual Account",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 18.0,
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isCardFrozen ? Icons.lock_outline : Icons.lock_open_outlined,
              color: _isCardFrozen
                  ? Colors.red
                  : ConstantColor.headingTextPrimary,
            ),
            tooltip: _isCardFrozen ? "Unfreeze Card" : "Freeze Card",
            onPressed: () {
              setState(() {
                _isCardFrozen = !_isCardFrozen;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isCardFrozen
                        ? "Virtual Card Frozen"
                        : "Virtual Card Unfrozen",
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Virtual Card Widget
            Stack(
              children: [
                VirtualCardWidget(
                  accountType: widget.accountType,
                  cardHolderName: widget.userName,
                  accountNumber: widget.accountNumber,
                  bankName: widget.bankName,
                  showAccountDetails: false,
                ),
                if (_isCardFrozen)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.ac_unit,
                              color: Colors.cyanAccent,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            googleSansText(
                              text: "CARD FROZEN",
                              colors: Colors.white,
                              fontWeight: FontWeight.bold,
                              size: 16.0,
                              letterSpacing: 2.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Card details toggle (Show CVV / Full details)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    googleSansText(
                      text: "CVV: ",
                      colors: ConstantColor.paragraphTextSecondary,
                      size: 13.0,
                      fontWeight: FontWeight.w500,
                    ),
                    googleSansText(
                      text: _showCVV ? "892" : "•••",
                      colors: ConstantColor.headingTextPrimary,
                      size: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showCVV = !_showCVV;
                    });
                  },
                  icon: Icon(
                    _showCVV
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                    color: isBusiness
                        ? Colors.teal.shade800
                        : ConstantColor.blueBackground,
                  ),
                  label: googleSansText(
                    text: _showCVV ? "Hide CVV" : "Show CVV",
                    colors: isBusiness
                        ? Colors.teal.shade800
                        : ConstantColor.blueBackground,
                    fontWeight: FontWeight.w600,
                    size: 13.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Account Balance & Details Card
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          googleSansText(
                            text: isBusiness
                                ? "Business Virtual Balance"
                                : "Virtual Account Balance",
                            colors: ConstantColor.paragraphTextSecondary,
                            size: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                          const SizedBox(height: 4.0),
                          googleSansText(
                            text: isBusiness ? "₦485,000.00" : "₦250,000.00",
                            colors: ConstantColor.headingTextPrimary,
                            size: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 6.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 14,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            googleSansText(
                              text: "Active",
                              colors: Colors.green,
                              fontWeight: FontWeight.bold,
                              size: 12.0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  const Divider(height: 1),
                  const SizedBox(height: 16.0),

                  // Account Info
                  _buildCopyableRow(
                    label: "Bank Name",
                    value: widget.bankName,
                    onCopy: () =>
                        _copyToClipboard(widget.bankName, "Bank Name"),
                  ),
                  const SizedBox(height: 12.0),
                  _buildCopyableRow(
                    label: "Account Number",
                    value: widget.accountNumber,
                    onCopy: () => _copyToClipboard(
                      widget.accountNumber,
                      "Account Number",
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  _buildCopyableRow(
                    label: isBusiness ? "Business Name" : "Account Name",
                    value: widget.userName,
                    onCopy: () =>
                        _copyToClipboard(widget.userName, "Account Name"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Quick Actions
            googleSansText(
              text: "Quick Actions",
              colors: ConstantColor.headingTextPrimary,
              fontWeight: FontWeight.bold,
              size: 16.0,
            ),
            const SizedBox(height: 14.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: isBusiness
                  ? [
                      _buildQuickAction(
                        icon: Icons.qr_code_2_rounded,
                        label: "Receive Payout",
                        onTap: () {
                          _copyToClipboard(
                            widget.accountNumber,
                            "Business Account Number",
                          );
                        },
                      ),
                      _buildQuickAction(
                        icon: Icons.send_to_mobile_rounded,
                        label: "Pay Vendor",
                        onTap: () {},
                      ),
                      _buildQuickAction(
                        icon: Icons.receipt_long_outlined,
                        label: "Invoices",
                        onTap: () {},
                      ),
                      _buildQuickAction(
                        icon: Icons.savings_outlined,
                        label: "Tax Reserve",
                        onTap: () {},
                      ),
                    ]
                  : [
                      _buildQuickAction(
                        icon: Icons.add_circle_outline,
                        label: "Top Up",
                        onTap: () {
                          _copyToClipboard(
                            widget.accountNumber,
                            "Account Number",
                          );
                        },
                      ),
                      _buildQuickAction(
                        icon: Icons.swap_horiz_rounded,
                        label: "Transfer",
                        onTap: () {},
                      ),
                      _buildQuickAction(
                        icon: Icons.receipt_long_outlined,
                        label: "Pay Bills",
                        onTap: () {},
                      ),
                      _buildQuickAction(
                        icon: Icons.work_outline,
                        label: "Salary Deposit",
                        onTap: () {
                          _copyToClipboard(
                            widget.accountNumber,
                            "Account Number for Salary Deposit",
                          );
                        },
                      ),
                    ],
            ),
            const SizedBox(height: 28.0),

            // Transaction History Header & Filters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                googleSansText(
                  text: isBusiness
                      ? "Business Activity"
                      : "Wallet Transactions",
                  colors: ConstantColor.headingTextPrimary,
                  fontWeight: FontWeight.bold,
                  size: 16.0,
                ),
                googleSansText(
                  text: "View All",
                  colors: isBusiness
                      ? Colors.teal.shade800
                      : ConstantColor.blueBackground,
                  fontWeight: FontWeight.bold,
                  size: 13.0,
                ),
              ],
            ),
            const SizedBox(height: 12.0),

            // Filter Chips
            Row(
              children: [
                _buildFilterChip("All", 0),
                const SizedBox(width: 8.0),
                _buildFilterChip(isBusiness ? "Payouts" : "Inflow", 1),
                const SizedBox(width: 8.0),
                _buildFilterChip(isBusiness ? "Expenses" : "Outflow", 2),
              ],
            ),
            const SizedBox(height: 16.0),

            // Transactions List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredTransactions.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 10.0),
              itemBuilder: (context, index) {
                final item = _filteredTransactions[index];
                return Container(
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: (item['color'] as Color).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: item['color'] as Color,
                          size: 20.0,
                        ),
                      ),
                      const SizedBox(width: 14.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            googleSansText(
                              text: item['title'] as String,
                              colors: ConstantColor.headingTextPrimary,
                              fontWeight: FontWeight.w600,
                              size: 14.0,
                            ),
                            const SizedBox(height: 3.0),
                            googleSansText(
                              text: item['subtitle'] as String,
                              colors: ConstantColor.paragraphTextSecondary,
                              fontWeight: FontWeight.w400,
                              size: 12.0,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          googleSansText(
                            text: item['amount'] as String,
                            colors: item['type'] == 'inflow'
                                ? Colors.green
                                : ConstantColor.headingTextPrimary,
                            fontWeight: FontWeight.bold,
                            size: 14.0,
                          ),
                          const SizedBox(height: 3.0),
                          googleSansText(
                            text: item['date'] as String,
                            colors: ConstantColor.paragraphTextSecondary,
                            fontWeight: FontWeight.w400,
                            size: 11.0,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_selectedFilterIndex == 1) {
      return _allTransactions.where((t) => t['type'] == 'inflow').toList();
    } else if (_selectedFilterIndex == 2) {
      return _allTransactions.where((t) => t['type'] == 'outflow').toList();
    }
    return _allTransactions;
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilterIndex == index;
    final primaryColor = widget.accountType.isBusiness
        ? Colors.teal.shade800
        : ConstantColor.blueBackground;

    return ChoiceChip(
      label: googleSansText(
        text: label,
        colors: isSelected ? Colors.white : ConstantColor.paragraphTextPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        size: 12.5,
      ),
      selected: isSelected,
      selectedColor: primaryColor,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(
          color: isSelected ? primaryColor : Colors.grey.shade300,
        ),
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilterIndex = index;
          });
        }
      },
    );
  }

  Widget _buildCopyableRow({
    required String label,
    required String value,
    required VoidCallback onCopy,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        googleSansText(
          text: label,
          colors: ConstantColor.paragraphTextSecondary,
          fontWeight: FontWeight.w500,
          size: 13.0,
        ),
        Row(
          children: [
            googleSansText(
              text: value,
              colors: ConstantColor.headingTextPrimary,
              fontWeight: FontWeight.bold,
              size: 13.5,
            ),
            const SizedBox(width: 6.0),
            InkWell(
              onTap: onCopy,
              borderRadius: BorderRadius.circular(4.0),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.copy_rounded,
                  size: 16.0,
                  color: widget.accountType.isBusiness
                      ? Colors.teal.shade800
                      : ConstantColor.blueBackground,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final primaryColor = widget.accountType.isBusiness
        ? Colors.teal.shade800
        : ConstantColor.blueBackground;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: primaryColor, size: 24.0),
          ),
          const SizedBox(height: 8.0),
          googleSansText(
            text: label,
            colors: ConstantColor.paragraphTextPrimary,
            fontWeight: FontWeight.w600,
            size: 12.0,
          ),
        ],
      ),
    );
  }
}
