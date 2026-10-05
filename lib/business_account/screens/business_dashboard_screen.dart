import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/business/business_theme.dart';
import '../../../shared/widgets/app_text.dart';
import '../sidebar/business_sidebar.dart';
import '../../../shared/features/inventory/screens/inventory_list_screen.dart';

class BusinessDashboardScreen extends StatefulWidget {
  const BusinessDashboardScreen({super.key});

  @override
  State<BusinessDashboardScreen> createState() =>
      _BusinessDashboardScreenState();
}

class _BusinessDashboardScreenState extends State<BusinessDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedFilter = 'This Month';
  final List<String> _filters = [
    'This Month',
    'This Quarter',
    'This Year',
    'All Time',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: BusinessTheme.backgroundLight,
      drawer: const BusinessSidebar(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.bars,
            color: BusinessTheme.charcoal,
            size: 20,
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: BusinessTheme.primaryAmber.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const AppText.subtitle(
            'V',
            style: TextStyle(
              color: BusinessTheme.primaryAmber,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.cloudArrowUp,
              color: BusinessTheme.charcoal,
              size: 20,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const AppText.title(
                'Welcome, Victory',
                style: TextStyle(
                  color: BusinessTheme.charcoal,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const AppText.paragraph(
                'Your business command centre is ready.',
                style: TextStyle(color: BusinessTheme.textMuted),
              ),
              const SizedBox(height: 24),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFilter = filter),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? BusinessTheme.primaryAmber.withValues(
                                    alpha: 0.1,
                                  )
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? BusinessTheme.primaryAmber
                                  : Colors.grey.shade300,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: AppText.paragraph(
                            filter,
                            style: TextStyle(
                              color: isSelected
                                  ? BusinessTheme.charcoal
                                  : BusinessTheme.textMuted,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: FontAwesomeIcons.arrowTrendDown,
                      iconColor: BusinessTheme.success,
                      iconBgColor: BusinessTheme.success.withValues(alpha: 0.1),
                      title: 'Total Revenue',
                      amount: '₦0',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      icon: FontAwesomeIcons.arrowTrendUp,
                      iconColor: BusinessTheme.danger,
                      iconBgColor: BusinessTheme.danger.withValues(alpha: 0.1),
                      title: 'Total Expense',
                      amount: '₦0',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Net Profit Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BusinessTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: BusinessTheme.primaryAmber.withValues(
                          alpha: 0.1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.chartLine,
                        color: BusinessTheme.primaryAmber,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        AppText.paragraph(
                          'Net Profit',
                          style: TextStyle(color: BusinessTheme.textMuted),
                        ),
                        SizedBox(height: 4),
                        AppText.subtitle(
                          '₦0',
                          style: TextStyle(
                            color: BusinessTheme.charcoal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Empty State Action Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: BusinessTheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            BusinessTheme.primaryAmber.withValues(alpha: 0.2),
                            BusinessTheme.surface,
                          ],
                          radius: 0.8,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.rocket,
                        color: BusinessTheme.charcoal,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const AppText.subtitle(
                      "Let's get down to business",
                      style: TextStyle(
                        color: BusinessTheme.charcoal,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const AppText.paragraph(
                      'Start by adding your first invoice, expense, or product to see your business health and insights here.',
                      style: TextStyle(
                        color: BusinessTheme.textMuted,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Create Invoice Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BusinessTheme.charcoal,
                          foregroundColor: BusinessTheme.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            FaIcon(FontAwesomeIcons.plus, size: 16),
                            SizedBox(width: 8),
                            AppText.button(
                              'Create Invoice',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: BusinessTheme.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Secondary Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildSecondaryActionButton(
                            icon: FontAwesomeIcons.fileInvoice,
                            label: 'Log Expense',
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSecondaryActionButton(
                            icon: FontAwesomeIcons.tag,
                            label: 'Record Sales',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const InventoryListScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required dynamic icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String amount,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BusinessTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: FaIcon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.paragraph(
                  title,
                  style: const TextStyle(
                    color: BusinessTheme.textMuted,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                AppText.subtitle(
                  amount,
                  style: const TextStyle(
                    color: BusinessTheme.charcoal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryActionButton({
    required dynamic icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: BusinessTheme.charcoal,
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(icon, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: AppText.button(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: BusinessTheme.charcoal,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
