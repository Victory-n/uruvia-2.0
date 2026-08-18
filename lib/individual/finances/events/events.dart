import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/individual/finances/events/classes/active_event_card.dart';
import 'package:uruvia/individual/finances/events/forms/create_saving_event_form.dart';
import 'package:uruvia/individual/finances/events/intro_modal.dart';
import 'package:uruvia/individual/finances/events/widgets/event_type_card.dart';
import 'package:uruvia/individual/finances/events/widgets/savings_types_sheet.dart';
import 'package:uruvia/individual/sidebar.dart';
import 'package:uruvia/shared_features/budgeting/budgeting_screen.dart';
import 'package:uruvia/widgets/custom_text.dart';

class IndividualEventsPage extends StatefulWidget {
  const IndividualEventsPage({super.key});

  @override
  State<IndividualEventsPage> createState() => _IndividualEventsPageState();
}

typedef EventsPage = IndividualEventsPage;

class _IndividualEventsPageState extends State<IndividualEventsPage> {
  @override
  void initState() {
    super.initState();
    // Auto trigger intro modal post-frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        EventsIntroModal.show(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const IndividualDrawer(selectedIndex: 4), // Index 4 for Events
      backgroundColor: ConstantColor.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: Builder(
          builder: (scaffoldContext) => IconButton(
            icon: const Icon(Icons.menu, color: ConstantColor.headingTextPrimary),
            onPressed: () {
              Scaffold.of(scaffoldContext).openDrawer();
            },
          ),
        ),
        title: googleSansText(
          text: "Finance Events",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 18.0,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: ConstantColor.blueBackground),
            onPressed: () => EventsIntroModal.show(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0058BE), Color(0xFF002F6C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: ConstantColor.blueBackground.withOpacity(0.2),
                    blurRadius: 12,
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
                      googleSansText(
                        text: "Events & Goals Hub",
                        colors: Colors.white,
                        fontWeight: FontWeight.bold,
                        size: 19.0,
                      ),
                      IconButton(
                        icon: const Icon(Icons.info_outline, color: Colors.white70),
                        onPressed: () => EventsIntroModal.show(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6.0),
                  googleSansText(
                    text: "Create savings, budget targets, group pools, and expense trackers.",
                    colors: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.normal,
                    size: 13.0,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Event Types Grid Preview
            googleSansText(
              text: "Create Event Type",
              colors: ConstantColor.headingTextPrimary,
              fontWeight: FontWeight.bold,
              size: 16.0,
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: EventTypeCard(
                    title: "Saving Event",
                    icon: Icons.savings_outlined,
                    color: Colors.green,
                    target: "Personal Goal",
                    onTap: () => SavingsTypesSheet.show(context),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: EventTypeCard(
                    title: "Expense Tracker",
                    icon: Icons.track_changes_outlined,
                    color: Colors.orange,
                    target: "Trip / Project",
                    onTap: () => CreateSavingEventForm.show(context, initialType: 'Locked Term'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: EventTypeCard(
                    title: "Group Savings",
                    icon: Icons.groups_outlined,
                    color: Colors.purple,
                    target: "Collaborative",
                    onTap: () => SavingsTypesSheet.show(context),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: EventTypeCard(
                    title: "Budget Plan",
                    icon: Icons.account_balance_outlined,
                    color: ConstantColor.blueBackground,
                    target: "Monthly Limits",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BudgetingScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28.0),

            // Active Events List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                googleSansText(
                  text: "Active Events",
                  colors: ConstantColor.headingTextPrimary,
                  fontWeight: FontWeight.bold,
                  size: 16.0,
                ),
                TextButton(
                  onPressed: () {},
                  child: googleSansText(
                    text: "View All",
                    colors: ConstantColor.blueBackground,
                    fontWeight: FontWeight.bold,
                    size: 13.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),

            // Sample Active Event Cards using imported ActiveEventCard
            const ActiveEventCard(
              title: "Summer Vacation 2026",
              category: "Saving Event",
              currentAmount: "₦180,000",
              targetAmount: "₦300,000",
              progress: 0.60,
              color: Colors.green,
              icon: Icons.flight_takeoff_rounded,
            ),
            const SizedBox(height: 12.0),
            const ActiveEventCard(
              title: "Wedding Gift Fund",
              category: "Group Savings",
              currentAmount: "₦45,000",
              targetAmount: "₦100,000",
              progress: 0.45,
              color: Colors.purple,
              icon: Icons.card_giftcard_rounded,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => SavingsTypesSheet.show(context),
        backgroundColor: ConstantColor.blueBackground,
        icon: const Icon(Icons.add, color: Colors.white),
        label: googleSansText(
          text: "Create Event",
          colors: Colors.white,
          fontWeight: FontWeight.bold,
          size: 13.5,
        ),
      ),
    );
  }
}
