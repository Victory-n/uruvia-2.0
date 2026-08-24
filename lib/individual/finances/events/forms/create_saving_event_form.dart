import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import '../../../../shared/widgets/custom_text.dart';

class CreateSavingEventForm extends StatefulWidget {
  final String initialType; // 'Target Goal' or 'Locked Term'

  const CreateSavingEventForm({super.key, this.initialType = 'Target Goal'});

  static Future<void> show(
    BuildContext context, {
    String initialType = 'Target Goal',
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateSavingEventForm(initialType: initialType),
    );
  }

  @override
  State<CreateSavingEventForm> createState() => _CreateSavingEventFormState();
}

class _CreateSavingEventFormState extends State<CreateSavingEventForm> {
  late String _selectedType;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String _selectedCategory = 'General';
  String _selectedDuration = '6 Months';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 180));

  final List<String> _categories = const [
    'General',
    'Gadgets',
    'Travel',
    'Emergency',
    'Education',
    'Business',
  ];

  final List<String> _lockDurations = const [
    '3 Months',
    '6 Months',
    '1 Year',
    '2 Years',
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      padding: EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0 + bottomInset),
      // mainAxisSize: MainAxisSize.min,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Drag Handle
            Center(
              child: Container(
                width: 40.0,
                height: 4.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 20.0),

            // Header Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                googleSansText(
                  text: "Create Saving Event",
                  colors: ConstantColor.headingTextPrimary,
                  fontWeight: FontWeight.bold,
                  size: 20.0,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: ConstantColor.paragraphTextSecondary,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Type Segment Selector
            Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FA),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTypeSegmentTile(
                      'Target Goal',
                      'Target Goal Savings',
                    ),
                  ),
                  Expanded(
                    child: _buildTypeSegmentTile(
                      'Locked Term',
                      'Fixed Locked Savings',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),

            // Event Name Input
            googleSansText(
              text: "Event Name",
              colors: ConstantColor.headingTextPrimary,
              fontWeight: FontWeight.bold,
              size: 13.5,
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: _selectedType == 'Target Goal'
                    ? "e.g. New Laptop Fund"
                    : "e.g. 6-Month Emergency Vault",
                hintStyle: TextStyle(
                  fontFamily: "googleSans",
                  fontSize: 14.0,
                  color: ConstantColor.paragraphTextSecondary.withOpacity(0.6),
                ),
                filled: true,
                fillColor: const Color(0xFFF9FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(
                    color: ConstantColor.blueBackground,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 14.0,
                ),
              ),
            ),
            const SizedBox(height: 18.0),

            // Target Amount Input
            googleSansText(
              text: _selectedType == 'Target Goal'
                  ? "Target Amount (₦)"
                  : "Deposit Amount (₦)",
              colors: ConstantColor.headingTextPrimary,
              fontWeight: FontWeight.bold,
              size: 13.5,
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.numbers_rounded,
                  color: ConstantColor.blueBackground,
                ),
                hintText: "e.g. 500,000",
                hintStyle: TextStyle(
                  fontFamily: "googleSans",
                  fontSize: 14.0,
                  color: ConstantColor.paragraphTextSecondary.withOpacity(0.6),
                ),
                filled: true,
                fillColor: const Color(0xFFF9FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(
                    color: ConstantColor.blueBackground,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 14.0,
                ),
              ),
            ),
            const SizedBox(height: 18.0),

            // Category Chips
            googleSansText(
              text: "Category Tag",
              colors: ConstantColor.headingTextPrimary,
              fontWeight: FontWeight.bold,
              size: 13.5,
            ),
            const SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: googleSansText(
                    text: cat,
                    colors: isSelected
                        ? Colors.white
                        : ConstantColor.paragraphTextPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    size: 12.5,
                  ),
                  selected: isSelected,
                  selectedColor: ConstantColor.blueBackground,
                  backgroundColor: const Color(0xFFF0F4FA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategory = cat);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 18.0),

            // Target Date or Lock Duration
            if (_selectedType == 'Target Goal') ...[
              googleSansText(
                text: "Target Completion Date",
                colors: ConstantColor.headingTextPrimary,
                fontWeight: FontWeight.bold,
                size: 13.5,
              ),
              const SizedBox(height: 8.0),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 1825)),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                borderRadius: BorderRadius.circular(12.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 14.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFC),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      googleSansText(
                        text:
                            "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                        colors: ConstantColor.headingTextPrimary,
                        fontWeight: FontWeight.w600,
                        size: 14.0,
                      ),
                      const Icon(
                        Icons.calendar_month_outlined,
                        color: ConstantColor.blueBackground,
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              googleSansText(
                text: "Lock Duration",
                colors: ConstantColor.headingTextPrimary,
                fontWeight: FontWeight.bold,
                size: 13.5,
              ),
              const SizedBox(height: 8.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _lockDurations.map((dur) {
                  final isSelected = _selectedDuration == dur;
                  return ChoiceChip(
                    label: googleSansText(
                      text: dur,
                      colors: isSelected
                          ? Colors.white
                          : ConstantColor.paragraphTextPrimary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      size: 12.5,
                    ),
                    selected: isSelected,
                    selectedColor: Colors.orange,
                    backgroundColor: const Color(0xFFF0F4FA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedDuration = dur);
                      }
                    },
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 28.0),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50.0,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: googleSansText(
                        text: "Saving event created successfully! (UI Mode)",
                        colors: Colors.white,
                        fontWeight: FontWeight.bold,
                        size: 13.5,
                      ),
                      backgroundColor: ConstantColor.blueBackground,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedType == 'Target Goal'
                      ? ConstantColor.blueBackground
                      : Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  elevation: 0.0,
                ),
                child: googleSansText(
                  text: "Create Saving Event",
                  colors: Colors.white,
                  fontWeight: FontWeight.bold,
                  size: 15.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSegmentTile(String typeValue, String label) {
    final isSelected = _selectedType == typeValue;

    return InkWell(
      onTap: () => setState(() => _selectedType = typeValue),
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: googleSansText(
            text: label,
            colors: isSelected
                ? (typeValue == 'Target Goal'
                      ? ConstantColor.blueBackground
                      : Colors.orange)
                : ConstantColor.paragraphTextSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            size: 12.5,
          ),
        ),
      ),
    );
  }
}
