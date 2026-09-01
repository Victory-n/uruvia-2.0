import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/shared/features/budgeting/widgets/budget_card_widget.dart';
import 'package:uruvia/shared/features/budgeting/widgets/budget_suggestions_card.dart';
import '../../widgets/custom_text.dart';
import '../calculator/savings_calculator_screen.dart';
import 'forms/create_budget_modal.dart';
import 'forms/create_budget_wizard.dart';
import 'logic/budget_isolate.dart';
import 'models/budget_item.dart';
import 'models/budget_plan.dart';

class BudgetingScreen extends StatefulWidget {
  final bool isBusiness;

  const BudgetingScreen({
    super.key,
    this.isBusiness = false,
  });

  @override
  State<BudgetingScreen> createState() => _BudgetingScreenState();
}

class _BudgetingScreenState extends State<BudgetingScreen> {
  late BudgetPlan _currentPlan;
  BudgetAnalysisResult? _analysis;
  bool _isLoadingIsolate = true;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    // Default mock budget plan for initial demonstration
    _currentPlan = BudgetPlan(
      id: 'plan_1',
      title: widget.isBusiness
          ? 'Business Operational Budget'
          : 'Personal Monthly Budget',
      totalIncome: 350000.0,
      cycle: BudgetCycle.monthly,
      startDate: now.subtract(const Duration(days: 10)),
      endDate: now.add(const Duration(days: 20)),
      isBusiness: widget.isBusiness,
      items: const [
        BudgetItem(
          id: '1',
          categoryName: 'Feeding & Groceries',
          icon: Icons.restaurant_outlined,
          allocatedAmount: 80000,
          spentAmount: 52000,
          color: Colors.green,
        ),
        BudgetItem(
          id: '2',
          categoryName: 'Transportation',
          icon: Icons.directions_bus_outlined,
          allocatedAmount: 45000,
          spentAmount: 38000,
          softStopThreshold: 0.8,
          color: Colors.blue,
        ),
        BudgetItem(
          id: '3',
          categoryName: 'Choplife & Outings',
          icon: Icons.sports_esports_outlined,
          allocatedAmount: 40000,
          spentAmount: 39500,
          isHardStopEnabled: true,
          color: Colors.purple,
        ),
        BudgetItem(
          id: '4',
          categoryName: 'Health & Pharmacy',
          icon: Icons.medical_services_outlined,
          allocatedAmount: 30000,
          spentAmount: 12000,
          color: Colors.orange,
        ),
      ],
    );

    _runIsolateAnalysis();
  }

  Future<void> _runIsolateAnalysis() async {
    setState(() => _isLoadingIsolate = true);

    // Offload budget analysis & suggestion calculations to Isolate (notes.txt rule #2)
    final res = await BudgetIsolateService.analyze(_currentPlan);

    if (mounted) {
      setState(() {
        _analysis = res;
        _isLoadingIsolate = false;
      });
    }
  }

  void _addOrUpdateItem(BudgetItem item) {
    final existingIndex = _currentPlan.items.indexWhere((i) => i.id == item.id);
    final newItems = List<BudgetItem>.from(_currentPlan.items);

    if (existingIndex >= 0) {
      newItems[existingIndex] = item;
    } else {
      newItems.add(item);
    }

    setState(() {
      _currentPlan = _currentPlan.copyWith(items: newItems);
    });

    _runIsolateAnalysis();
  }

  void _toggleHardStop(String itemId, bool value) {
    final index = _currentPlan.items.indexWhere((i) => i.id == itemId);
    if (index >= 0) {
      final updatedItem = _currentPlan.items[index].copyWith(
        isHardStopEnabled: value,
      );
      _addOrUpdateItem(updatedItem);
    }
  }

  void _openCalculatorSync() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SavingsCalculatorScreen(isBusiness: widget.isBusiness),
      ),
    );
  }

  void _openWizard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateBudgetWizardScreen(
          onCreated: (newPlan) {
            setState(() => _currentPlan = newPlan);
            _runIsolateAnalysis();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _currentPlan.items.where((item) {
      if (_selectedFilter == 'Warning/Depleted') {
        return item.status == BudgetStatus.warning ||
            item.status == BudgetStatus.depleted ||
            item.status == BudgetStatus.stopped;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: ConstantColor.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: true,
        title: googleSansText(
          text: _currentPlan.title,
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 18.0,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.auto_fix_high_rounded,
              color: ConstantColor.blueBackground,
            ),
            tooltip: "Budget Wizard",
            onPressed: _openWizard,
          ),
          IconButton(
            icon: const Icon(
              Icons.calculate_outlined,
              color: ConstantColor.blueBackground,
            ),
            tooltip: "Savings Calculator Sync",
            onPressed: _openCalculatorSync,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: ConstantColor.blueBackground,
        icon: const Icon(Icons.add, color: Colors.white),
        label: googleSansText(
          text: "New Category",
          colors: Colors.white,
          fontWeight: FontWeight.bold,
          size: 13.5,
        ),
        onPressed: () {
          CreateBudgetModal.show(context, onSave: _addOrUpdateItem);
        },
      ),
      body: RefreshIndicator(
        onRefresh: _runIsolateAnalysis,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Overview Banner Card
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        googleSansText(
                          text:
                              "${_currentPlan.cycle.displayName} Budget Summary",
                          colors: Colors.white.withOpacity(0.85),
                          fontWeight: FontWeight.w600,
                          size: 13.0,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 3.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: googleSansText(
                            text: "${_currentPlan.remainingDays} Days Left",
                            colors: Colors.white,
                            fontWeight: FontWeight.bold,
                            size: 10.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    googleSansText(
                      text:
                          "₦${_currentPlan.totalSpent.toStringAsFixed(0)} / ₦${_currentPlan.totalAllocated.toStringAsFixed(0)}",
                      colors: Colors.white,
                      fontWeight: FontWeight.bold,
                      size: 24.0,
                    ),
                    const SizedBox(height: 16.0),

                    // Velocity Safe Spend Row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                googleSansText(
                                  text: "Safe Daily Velocity",
                                  colors: Colors.white70,
                                  size: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                const SizedBox(height: 2.0),
                                googleSansText(
                                  text:
                                      "₦${_currentPlan.dailySafeSpend.toStringAsFixed(0)} / day",
                                  colors: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  size: 13.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                googleSansText(
                                  text: "Unbudgeted Income",
                                  colors: Colors.white70,
                                  size: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                const SizedBox(height: 2.0),
                                googleSansText(
                                  text:
                                      "₦${_currentPlan.unallocatedIncome.toStringAsFixed(0)}",
                                  colors: Colors.amberAccent,
                                  fontWeight: FontWeight.bold,
                                  size: 13.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),

              // 2. Smart Suggestions Banner
              if (_isLoadingIsolate)
                const LinearProgressIndicator()
              else if (_analysis != null && _analysis!.suggestions.isNotEmpty)
                BudgetSuggestionsCard(
                  suggestions: _analysis!.suggestions,
                  onActionTap: (sug) {
                    if (sug['type'] == 'unallocated') {
                      _openWizard();
                    } else {
                      CreateBudgetModal.show(context, onSave: _addOrUpdateItem);
                    }
                  },
                ),

              // Category Header & Filter Tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  googleSansText(
                    text: "Category Budgets",
                    colors: ConstantColor.headingTextPrimary,
                    fontWeight: FontWeight.bold,
                    size: 17.0,
                  ),
                  Row(
                    children: [
                      _buildFilterChip('All'),
                      const SizedBox(width: 6.0),
                      _buildFilterChip('Warning/Depleted'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14.0),

              // 4. Category Cards List
              if (filteredItems.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.search_off_rounded,
                        size: 40,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 8.0),
                      googleSansText(
                        text: "No categories match this filter.",
                        colors: ConstantColor.paragraphTextSecondary,
                        size: 13.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                )
              else
                ...filteredItems.map((item) {
                  return BudgetCardWidget(
                    item: item,
                    onTap: () {
                      CreateBudgetModal.show(
                        context,
                        initialItem: item,
                        onSave: _addOrUpdateItem,
                      );
                    },
                    onHardStopToggled: (val) => _toggleHardStop(item.id, val),
                  );
                }),

              const SizedBox(height: 60.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSel = _selectedFilter == label;
    return ChoiceChip(
      label: googleSansText(
        text: label,
        colors: isSel ? Colors.white : ConstantColor.paragraphTextPrimary,
        fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
        size: 11.5,
      ),
      selected: isSel,
      selectedColor: ConstantColor.blueBackground,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      onSelected: (val) {
        if (val) setState(() => _selectedFilter = label);
      },
    );
  }
}
