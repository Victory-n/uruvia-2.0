import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import '../../widgets/custom_text.dart';
import '../calculator/savings_calculator_screen.dart';
import 'forms/create_budget_modal.dart';
import 'forms/create_budget_wizard.dart';
import 'logic/budget_isolate.dart';
import 'logic/budget_repository.dart';
import 'models/budget_item.dart';
import 'models/budget_plan.dart';
import 'widgets/budget_card_widget.dart';
import 'widgets/budget_empty_state.dart';
import 'widgets/budget_filter_bar.dart';
import 'widgets/budget_overview_banner.dart';
import 'widgets/budget_suggestions_card.dart';

class BudgetingScreen extends StatefulWidget {
  final bool isBusiness;

  const BudgetingScreen({super.key, this.isBusiness = false});

  @override
  State<BudgetingScreen> createState() => _BudgetingScreenState();
}

class _BudgetingScreenState extends State<BudgetingScreen> {
  BudgetPlan? _currentPlan;
  List<BudgetItem> _filteredItems = const [];
  BudgetAnalysisResult? _analysis;
  bool _isLoading = true;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadBudgetPlan();
  }

  Future<void> _loadBudgetPlan() async {
    setState(() => _isLoading = true);

    // Fetch budget plan via decoupled offline-first repository (notes.txt rule #3)
    final plan = await BudgetRepository.instance.getActiveBudgetPlan(
      isBusiness: widget.isBusiness,
    );

    if (mounted) {
      _currentPlan = plan;
      await _runIsolateAnalysisAndFilter();
    }
  }

  Future<void> _runIsolateAnalysisAndFilter() async {
    if (_currentPlan == null) return;

    // Offload all heavy analysis, calculations & category filtering to Isolate (notes.txt rule #1)
    final analysisFuture = BudgetIsolateService.analyze(_currentPlan!);
    final filteredItemsFuture = BudgetIsolateService.filterItems(
      items: _currentPlan!.items,
      filter: _selectedFilter,
    );

    final results = await Future.wait([analysisFuture, filteredItemsFuture]);

    if (mounted) {
      setState(() {
        _analysis = results[0] as BudgetAnalysisResult;
        _filteredItems = results[1] as List<BudgetItem>;
        _isLoading = false;
      });
    }
  }

  Future<void> _onFilterChanged(String filter) async {
    setState(() => _selectedFilter = filter);
    if (_currentPlan == null) return;

    // Filter list inside background Isolate (notes.txt rule #1)
    final filtered = await BudgetIsolateService.filterItems(
      items: _currentPlan!.items,
      filter: filter,
    );

    if (mounted) {
      setState(() => _filteredItems = filtered);
    }
  }

  Future<void> _addOrUpdateItem(BudgetItem item) async {
    if (_currentPlan == null) return;

    // Offload item list modification to background Isolate (notes.txt rule #1)
    final newItems = await BudgetIsolateService.addItemOrUpdate(
      items: _currentPlan!.items,
      newItem: item,
    );

    final updatedPlan = _currentPlan!.copyWith(items: newItems);

    setState(() {
      _currentPlan = updatedPlan;
      _isLoading = true;
    });

    // Save to repository (offline SQLite cache + Supabase sync)
    await BudgetRepository.instance.saveBudgetItem(updatedPlan.id, item);

    if (mounted) {
      await _runIsolateAnalysisAndFilter();
    }
  }

  Future<void> _toggleHardStop(String itemId, bool value) async {
    if (_currentPlan == null) return;

    // Offload list modification to background Isolate (notes.txt rule #1)
    final newItems = await BudgetIsolateService.toggleHardStopInItems(
      items: _currentPlan!.items,
      itemId: itemId,
      isHardStop: value,
    );

    final updatedPlan = _currentPlan!.copyWith(items: newItems);

    setState(() {
      _currentPlan = updatedPlan;
    });

    final updatedItem = newItems.firstWhere((i) => i.id == itemId);
    await BudgetRepository.instance.saveBudgetItem(updatedPlan.id, updatedItem);

    if (mounted) {
      await _runIsolateAnalysisAndFilter();
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
          onCreated: (newPlan) async {
            setState(() {
              _currentPlan = newPlan;
              _isLoading = true;
            });
            await BudgetRepository.instance.saveBudgetPlan(newPlan);
            if (mounted) {
              await _runIsolateAnalysisAndFilter();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = _currentPlan;

    return Scaffold(
      backgroundColor: ConstantColor.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: true,
        title: googleSansText(
          text: "Budget Planner",
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
        onRefresh: _loadBudgetPlan,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Overview Banner (Extracted per notes.txt rule #5)
              BudgetOverviewBanner(
                cycleDisplayName: plan?.cycle.displayName ?? "Monthly",
                remainingDays: _analysis?.remainingDays ?? 0,
                totalSpent: _analysis?.totalSpent ?? 0.0,
                totalAllocated: _analysis?.totalAllocated ?? 0.0,
                dailySafeSpend: _analysis?.dailySafeSpend ?? 0.0,
                unallocatedIncome: _analysis?.unallocatedIncome ?? 0.0,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 20.0),

              // 2. Smart Suggestions Banner
              if (_isLoading)
                const LinearProgressIndicator(
                  color: ConstantColor.blueBackground,
                )
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

              // 3. Category Header & Filter Tabs (Extracted per notes.txt rule #5)
              BudgetFilterBar(
                selectedFilter: _selectedFilter,
                onFilterChanged: _onFilterChanged,
              ),
              const SizedBox(height: 14.0),

              // 4. Category Cards List
              if (_filteredItems.isEmpty && !_isLoading)
                (_currentPlan?.items.isEmpty ?? true)
                    ? BudgetEmptyState(
                        title: "No Budget Categories",
                        message:
                            "You haven't added any category budgets yet. Tap below to create your first category cap or launch the Budget Wizard.",
                        actionLabel: "Add Category",
                        onAction: () {
                          CreateBudgetModal.show(
                            context,
                            onSave: _addOrUpdateItem,
                          );
                        },
                      )
                    : BudgetEmptyState(
                        title: "No Matching Categories",
                        message:
                            "No budget categories currently match the '$_selectedFilter' filter.",
                      )
              else
                ..._filteredItems.map((item) {
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
}
