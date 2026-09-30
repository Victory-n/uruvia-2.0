import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../widgets/app_text.dart';
import '../../../../theme/individual/app_theme.dart';
import 'add_budget_screen.dart';

class BudgetingMainScreen extends StatelessWidget {
  const BudgetingMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText.subtitle('Budgets'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Implement refresh logic here
          await Future.delayed(const Duration(seconds: 1));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.wallet,
                      size: 64,
                      color: AppTheme.textMuted.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const AppText.paragraph(
                      'No budgets created yet.',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddBudgetScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.sleekBlue,
        icon: const FaIcon(FontAwesomeIcons.plus, color: AppTheme.white, size: 18),
        label: const AppText.button('Add Budget', style: TextStyle(color: AppTheme.white)),
      ),
    );
  }
}
