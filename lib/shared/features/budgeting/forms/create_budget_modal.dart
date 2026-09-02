import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/services/currency_service.dart';
import '../../../widgets/custom_text.dart';
import '../models/budget_item.dart';

class CreateBudgetModal extends StatefulWidget {
  final BudgetItem? initialItem;
  final ValueChanged<BudgetItem> onSave;

  const CreateBudgetModal({super.key, this.initialItem, required this.onSave});

  static Future<void> show(
    BuildContext context, {
    BudgetItem? initialItem,
    required ValueChanged<BudgetItem> onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          CreateBudgetModal(initialItem: initialItem, onSave: onSave),
    );
  }

  @override
  State<CreateBudgetModal> createState() => _CreateBudgetModalState();
}

class _CreateBudgetModalState extends State<CreateBudgetModal> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  bool _isHardStop = false;
  IconData _selectedIcon = Icons.category_outlined;
  Color _selectedColor = Colors.blue;

  final List<IconData> _availableIcons = const [
    Icons.restaurant_outlined,
    Icons.directions_bus_outlined,
    Icons.sports_esports_outlined,
    Icons.medical_services_outlined,
    Icons.shopping_bag_outlined,
    Icons.home_work_outlined,
    Icons.school_outlined,
    Icons.flight_takeoff_outlined,
  ];

  final List<Color> _availableColors = const [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialItem?.categoryName ?? '',
    );
    _amountController = TextEditingController(
      text: widget.initialItem != null
          ? widget.initialItem!.allocatedAmount.toStringAsFixed(0)
          : '',
    );
    _isHardStop = widget.initialItem?.isHardStopEnabled ?? false;
    _selectedIcon = widget.initialItem?.icon ?? Icons.restaurant_outlined;
    _selectedColor = widget.initialItem?.color ?? Colors.blue;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;

    if (name.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid category name and amount."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final newItem = BudgetItem(
      id:
          widget.initialItem?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      categoryName: name,
      icon: _selectedIcon,
      allocatedAmount: amount,
      spentAmount: widget.initialItem?.spentAmount ?? 0.0,
      isHardStopEnabled: _isHardStop,
      color: _selectedColor,
    );

    widget.onSave(newItem);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final symbol = CurrencyService.instance.activeSymbol;

    return Container(
      padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              googleSansText(
                text: widget.initialItem != null
                    ? "Edit Category Budget"
                    : "New Category Budget",
                colors: ConstantColor.headingTextPrimary,
                fontWeight: FontWeight.bold,
                size: 18.0,
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // Category Name Field
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "Category Name (e.g. Feeding, Choplife)",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
          const SizedBox(height: 14.0),

          // Allocated Amount Field
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Allocated Budget Amount ($symbol)",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          // Icon Selector
          googleSansText(
            text: "Select Category Icon",
            colors: ConstantColor.paragraphTextSecondary,
            fontWeight: FontWeight.bold,
            size: 12.5,
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _availableIcons.map((icon) {
              final isSel = icon == _selectedIcon;
              return InkWell(
                onTap: () => setState(() => _selectedIcon = icon),
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: isSel
                        ? ConstantColor.blueBackground.withValues(alpha: 0.12)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: isSel
                          ? ConstantColor.blueBackground
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: isSel ? ConstantColor.blueBackground : Colors.grey,
                    size: 20.0,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16.0),

          // Color Selector
          googleSansText(
            text: "Category Theme Color",
            colors: ConstantColor.paragraphTextSecondary,
            fontWeight: FontWeight.bold,
            size: 12.5,
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _availableColors.map((color) {
              final isSel = color == _selectedColor;
              return InkWell(
                onTap: () => setState(() => _selectedColor = color),
                customBorder: const CircleBorder(),
                child: Container(
                  width: 28.0,
                  height: 28.0,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSel ? Colors.black : Colors.white,
                      width: isSel ? 2.5 : 1.0,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16.0),

          // Hard Stop Toggle Card
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: _isHardStop ? Colors.red.shade50 : const Color(0xFFF9FAFC),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: _isHardStop
                    ? Colors.red.shade200
                    : const Color(0xFFEEEEEE),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lock_clock_outlined,
                  color: _isHardStop
                      ? Colors.red.shade700
                      : ConstantColor.paragraphTextSecondary,
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      googleSansText(
                        text: "Enable Hard Stop",
                        colors: _isHardStop
                            ? Colors.red.shade700
                            : ConstantColor.headingTextPrimary,
                        fontWeight: FontWeight.bold,
                        size: 13.5,
                      ),
                      const SizedBox(height: 2.0),
                      googleSansText(
                        text: "Lock spending once 100% cap is reached.",
                        colors: ConstantColor.paragraphTextSecondary,
                        fontWeight: FontWeight.normal,
                        size: 11.5,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isHardStop,
                  activeThumbColor: Colors.redAccent,
                  onChanged: (val) => setState(() => _isHardStop = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 48.0,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ConstantColor.blueBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onPressed: _submit,
              child: googleSansText(
                text: widget.initialItem != null
                    ? "Update Category"
                    : "Add Category",
                colors: Colors.white,
                fontWeight: FontWeight.bold,
                size: 15.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
