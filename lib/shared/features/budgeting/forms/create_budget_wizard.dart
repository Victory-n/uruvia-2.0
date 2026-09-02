import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/services/currency_service.dart';
import '../../../widgets/custom_text.dart';
import '../logic/budget_isolate.dart';
import '../models/budget_item.dart';
import '../models/budget_plan.dart';

class CreateBudgetWizardScreen extends StatefulWidget {
  final ValueChanged<BudgetPlan> onCreated;

  const CreateBudgetWizardScreen({super.key, required this.onCreated});

  @override
  State<CreateBudgetWizardScreen> createState() =>
      _CreateBudgetWizardScreenState();
}

class _CreateBudgetWizardScreenState extends State<CreateBudgetWizardScreen> {
  int _currentStep = 0;
  BudgetCycle _selectedCycle = BudgetCycle.monthly;
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  bool _is503020Selected = true;
  List<BudgetItem> _wizardItems = [];
  bool _isGeneratingPreset = false;

  @override
  void dispose() {
    _incomeController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _generatePreset() async {
    final double income =
        double.tryParse(_incomeController.text.replaceAll(',', '')) ?? 0.0;
    setState(() => _isGeneratingPreset = true);

    if (_is503020Selected && income > 0) {
      final items = await BudgetIsolateService.generate503020Preset(income);
      if (mounted) {
        setState(() {
          _wizardItems = items;
          _isGeneratingPreset = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _wizardItems = [];
          _isGeneratingPreset = false;
        });
      }
    }
  }

  void _finishWizard() {
    final title = _titleController.text.trim().isEmpty
        ? "New Budget Plan"
        : _titleController.text.trim();
    final income =
        double.tryParse(_incomeController.text.replaceAll(',', '')) ?? 0.0;
    final now = DateTime.now();

    final plan = BudgetPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      totalIncome: income,
      cycle: _selectedCycle,
      startDate: now,
      endDate: now.add(Duration(days: _selectedCycle.defaultDays)),
      items: _wizardItems,
    );

    widget.onCreated(plan);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColor.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: googleSansText(
          text: "Create Budget Plan Wizard",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 18.0,
        ),
      ),
      body: Column(
        children: [
          // Step Progress Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                _buildStepIndicator(0, "1. Cycle"),
                const Expanded(child: Divider()),
                _buildStepIndicator(1, "2. Strategy"),
                const Expanded(child: Divider()),
                _buildStepIndicator(2, "3. Review"),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: _currentStep == 0
                  ? _buildStep1Cycle()
                  : _currentStep == 1
                  ? _buildStep2Strategy()
                  : _buildStep3Review(),
            ),
          ),
          // Footer Navigation Bar
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  OutlinedButton(
                    onPressed: () => setState(() => _currentStep--),
                    child: const Text("Back"),
                  )
                else
                  const SizedBox.shrink(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ConstantColor.blueBackground,
                  ),
                  onPressed: () async {
                    if (_currentStep == 0) {
                      setState(() => _currentStep = 1);
                    } else if (_currentStep == 1) {
                      await _generatePreset();
                      setState(() => _currentStep = 2);
                    } else {
                      _finishWizard();
                    }
                  },
                  child: googleSansText(
                    text: _currentStep == 2 ? "Finalize Budget" : "Continue",
                    colors: Colors.white,
                    fontWeight: FontWeight.bold,
                    size: 14.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int stepIndex, String label) {
    final isActive = _currentStep >= stepIndex;
    return Row(
      children: [
        CircleAvatar(
          radius: 12.0,
          backgroundColor: isActive
              ? ConstantColor.blueBackground
              : Colors.grey.shade300,
          child: Text(
            "${stepIndex + 1}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 6.0),
        googleSansText(
          text: label,
          colors: isActive ? ConstantColor.blueBackground : Colors.grey,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          size: 12.0,
        ),
      ],
    );
  }

  Widget _buildStep1Cycle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        googleSansText(
          text: "Select Budget Cycle",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 18.0,
        ),
        const SizedBox(height: 6.0),
        googleSansText(
          text: "Choose how often you want to track your spending limits.",
          colors: ConstantColor.paragraphTextSecondary,
          size: 13.0,
          fontWeight: FontWeight.w400,
        ),
        const SizedBox(height: 20.0),

        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: "Budget Plan Title",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
        const SizedBox(height: 20.0),

        ...BudgetCycle.values.map((cycle) {
          final isSel = _selectedCycle == cycle;
          return Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: isSel
                    ? ConstantColor.blueBackground
                    : const Color(0xFFEEEEEE),
                width: isSel ? 2.0 : 1.0,
              ),
            ),
            child: ListTile(
              onTap: () => setState(() => _selectedCycle = cycle),
              leading: Icon(
                cycle == BudgetCycle.monthly
                    ? Icons.calendar_month_outlined
                    : cycle == BudgetCycle.biWeekly
                    ? Icons.payments_outlined
                    : cycle == BudgetCycle.weekly
                    ? Icons.view_week_outlined
                    : Icons.edit_calendar_outlined,
                color: isSel
                    ? ConstantColor.blueBackground
                    : ConstantColor.paragraphTextSecondary,
              ),
              title: googleSansText(
                text: cycle.displayName,
                colors: isSel
                    ? ConstantColor.blueBackground
                    : ConstantColor.headingTextPrimary,
                fontWeight: FontWeight.bold,
                size: 15.0,
              ),
              subtitle: googleSansText(
                text: "Resets every ${cycle.defaultDays} days.",
                colors: ConstantColor.paragraphTextSecondary,
                size: 12.0,
                fontWeight: FontWeight.w600,
              ),
              trailing: isSel
                  ? const Icon(
                      Icons.check_circle,
                      color: ConstantColor.blueBackground,
                    )
                  : null,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStep2Strategy() {
    final symbol = CurrencyService.instance.activeSymbol;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        googleSansText(
          text: "Income & Allocation Strategy",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 18.0,
        ),
        const SizedBox(height: 6.0),
        googleSansText(
          text: "Enter your total expected income for this cycle.",
          colors: ConstantColor.paragraphTextSecondary,
          size: 13.0,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 20.0),

        TextField(
          controller: _incomeController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Total Expected Income ($symbol)",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
        const SizedBox(height: 24.0),

        googleSansText(
          text: "Choose Strategy Preset",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 15.0,
        ),
        const SizedBox(height: 12.0),

        // 50/30/20 Rule Card
        InkWell(
          onTap: () => setState(() => _is503020Selected = true),
          borderRadius: BorderRadius.circular(14.0),
          child: Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: _is503020Selected
                    ? ConstantColor.blueBackground
                    : const Color(0xFFEEEEEE),
                width: _is503020Selected ? 2.0 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _is503020Selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: _is503020Selected
                      ? ConstantColor.blueBackground
                      : Colors.grey,
                  size: 22.0,
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      googleSansText(
                        text: "50/30/20 Smart Rule (Recommended)",
                        colors: ConstantColor.headingTextPrimary,
                        fontWeight: FontWeight.bold,
                        size: 14.5,
                      ),
                      const SizedBox(height: 4.0),
                      googleSansText(
                        text:
                            "50% Needs (Feeding, Transport), 30% Wants (Choplife), 20% Savings Reserve.",
                        colors: ConstantColor.paragraphTextSecondary,
                        size: 12.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12.0),

        // Custom Categories Card
        InkWell(
          onTap: () => setState(() => _is503020Selected = false),
          borderRadius: BorderRadius.circular(14.0),
          child: Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: !_is503020Selected
                    ? ConstantColor.blueBackground
                    : const Color(0xFFEEEEEE),
                width: !_is503020Selected ? 2.0 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  !_is503020Selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: !_is503020Selected
                      ? ConstantColor.blueBackground
                      : Colors.grey,
                  size: 22.0,
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      googleSansText(
                        text: "Custom Categories",
                        colors: ConstantColor.headingTextPrimary,
                        fontWeight: FontWeight.bold,
                        size: 14.5,
                      ),
                      const SizedBox(height: 4.0),
                      googleSansText(
                        text: "Manually build your own custom category caps.",
                        colors: ConstantColor.paragraphTextSecondary,
                        size: 12.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3Review() {
    final symbol = CurrencyService.instance.activeSymbol;
    final double income =
        double.tryParse(_incomeController.text.replaceAll(',', '')) ?? 0.0;
    final double totalAllocated = _wizardItems.fold(
      0.0,
      (sum, i) => sum + i.allocatedAmount,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        googleSansText(
          text: "Review Generated Budget",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 18.0,
        ),
        const SizedBox(height: 6.0),
        googleSansText(
          text: "Review your generated category limits before finalizing.",
          colors: ConstantColor.paragraphTextSecondary,
          size: 13.0,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 16.0),

        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  googleSansText(
                    text: "Total Income",
                    colors: ConstantColor.paragraphTextSecondary,
                    size: 12.0,
                    fontWeight: FontWeight.w600,
                  ),
                  googleSansText(
                    text: "$symbol${income.toStringAsFixed(0)}",
                    colors: ConstantColor.headingTextPrimary,
                    fontWeight: FontWeight.bold,
                    size: 16.0,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  googleSansText(
                    text: "Total Allocated",
                    colors: ConstantColor.paragraphTextSecondary,
                    size: 12.0,
                    fontWeight: FontWeight.w600,
                  ),
                  googleSansText(
                    text: "$symbol${totalAllocated.toStringAsFixed(0)}",
                    colors: ConstantColor.blueBackground,
                    fontWeight: FontWeight.bold,
                    size: 16.0,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20.0),

        if (_isGeneratingPreset)
          const Center(child: CircularProgressIndicator())
        else if (_wizardItems.isEmpty)
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Center(
              child: googleSansText(
                text: "Custom plan initialized. You can add your custom category caps immediately after finalizing.",
                colors: ConstantColor.paragraphTextSecondary,
                size: 13.0,
                textAlign: TextAlign.center,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        else
          ..._wizardItems.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Row(
                children: [
                  Icon(item.icon, color: item.color),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: googleSansText(
                      text: item.categoryName,
                      colors: ConstantColor.headingTextPrimary,
                      fontWeight: FontWeight.bold,
                      size: 14.0,
                    ),
                  ),
                  googleSansText(
                    text: "$symbol${item.allocatedAmount.toStringAsFixed(0)}",
                    colors: ConstantColor.blueBackground,
                    fontWeight: FontWeight.bold,
                    size: 14.0,
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
