import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import '../shared/features/wallet/setup_virtual_account_modal.dart';
import '../shared/features/wallet/virtual_card_widget.dart';
import '../shared/features/wallet/wallet_page.dart';
import '../shared/widgets/custom_text.dart';

class IndividualDashboard extends StatefulWidget {
  final String userName;

  const IndividualDashboard({super.key, this.userName = "Alex"});

  @override
  State<IndividualDashboard> createState() => _IndividualDashboardState();
}

typedef Dashboard = IndividualDashboard;

class _IndividualDashboardState extends State<IndividualDashboard> {
  bool _isVirtualAccountSetup = false;

  void _openSetupModal() {
    SetupVirtualAccountModal.show(
      context,
      onSetupComplete: () {
        setState(() {
          _isVirtualAccountSetup = true;
        });
      },
    );
  }

  void _navigateToWalletPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IndividualWalletPage(userName: widget.userName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColor.lightBackground,
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
          text: "Individual Dashboard",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 18.0,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: ConstantColor.headingTextPrimary,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header Card (Pure UI)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [ConstantColor.blueBackground, Color(0xFF003C8F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: ConstantColor.blueBackground.withOpacity(0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  googleSansText(
                    text: "Welcome back, ${widget.userName}!",
                    colors: Colors.white,
                    fontWeight: FontWeight.bold,
                    size: 20.0,
                  ),
                  const SizedBox(height: 6.0),
                  googleSansText(
                    text:
                        "Here is your personal financial overview & account activity.",
                    colors: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.normal,
                    size: 13.5,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),

            // Overview Cards
            googleSansText(
              text: "Overview",
              colors: ConstantColor.headingTextPrimary,
              fontWeight: FontWeight.bold,
              size: 16.0,
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: "Total Balance",
                    value: "₦250,000.00",
                    icon: Icons.account_balance_wallet_outlined,
                    color: ConstantColor.blueBackground,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: _buildSummaryCard(
                    title: "Monthly Expenses",
                    value: "₦45,200.00",
                    icon: Icons.trending_down_rounded,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: "Monthly Income",
                    value: "₦180,000.00",
                    icon: Icons.trending_up_rounded,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: _buildSummaryCard(
                    title: "Savings Goal",
                    value: "₦500,000.00",
                    icon: Icons.savings_outlined,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28.0),

            // Virtual Account / Card Section
            _buildVirtualAccountSection(),
            const SizedBox(height: 24.0),

            // Quick Actions
            googleSansText(
              text: "Quick Actions",
              colors: ConstantColor.headingTextPrimary,
              fontWeight: FontWeight.bold,
              size: 16.0,
            ),
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: Icons.add_circle_outline,
                  label: "Add Income",
                  onTap: () {},
                ),
                _buildActionButton(
                  icon: Icons.remove_circle_outline,
                  label: "Add Expense",
                  onTap: () {},
                ),
                _buildActionButton(
                  icon: Icons.swap_horiz_rounded,
                  label: "Transfer",
                  onTap: () {},
                ),
                _buildActionButton(
                  icon: Icons.analytics_outlined,
                  label: "Reports",
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(icon, color: color, size: 20.0),
          ),
          const SizedBox(height: 12.0),
          googleSansText(
            text: title,
            colors: ConstantColor.paragraphTextSecondary,
            fontWeight: FontWeight.w500,
            size: 12.0,
          ),
          const SizedBox(height: 4.0),
          googleSansText(
            text: value,
            colors: ConstantColor.headingTextPrimary,
            fontWeight: FontWeight.bold,
            size: 17.0,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
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
                  color: ConstantColor.blueBackground.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: ConstantColor.blueBackground, size: 24.0),
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

  Widget _buildVirtualAccountSection() {
    if (_isVirtualAccountSetup) {
      return VirtualCardWidget(
        cardHolderName: widget.userName,
        accountNumber: "8123456789",
        bankName: "Uruvia MFB",
        onTap: _navigateToWalletPage,
      );
    } else {
      return _buildSetupVirtualAccountBanner();
    }
  }

  Widget _buildSetupVirtualAccountBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: ConstantColor.blueBackground.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ConstantColor.blueBackground.withOpacity(0.06),
            blurRadius: 12,
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
                  color: ConstantColor.blueBackground.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Icon(
                  Icons.add_card_rounded,
                  color: ConstantColor.blueBackground,
                  size: 24.0,
                ),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    googleSansText(
                      text: "Setup Virtual Account",
                      colors: ConstantColor.headingTextPrimary,
                      fontWeight: FontWeight.bold,
                      size: 16.0,
                    ),
                    const SizedBox(height: 2.0),
                    googleSansText(
                      text:
                          "Virtual debit card, salary transfers & direct spending.",
                      colors: ConstantColor.paragraphTextSecondary,
                      fontWeight: FontWeight.w400,
                      size: 12.5,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: _openSetupModal,
              icon: const Icon(
                Icons.flash_on_rounded,
                size: 18,
                color: Colors.white,
              ),
              label: googleSansText(
                text: "Setup Virtual Account Now",
                colors: Colors.white,
                fontWeight: FontWeight.bold,
                size: 14.0,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ConstantColor.blueBackground,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
