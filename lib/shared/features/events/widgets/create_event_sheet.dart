import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../widgets/app_text.dart';
import '../models/finance_event.dart';

class CreateEventSheet extends StatefulWidget {
  final Function(FinanceEvent) onEventCreated;

  const CreateEventSheet({
    super.key,
    required this.onEventCreated,
  });

  static Future<void> show(
    BuildContext context,
    Function(FinanceEvent) onCreated,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateEventSheet(onEventCreated: onCreated),
    );
  }

  @override
  State<CreateEventSheet> createState() => _CreateEventSheetState();
}

class _CreateEventSheetState extends State<CreateEventSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _initialDepositController = TextEditingController();
  final _participantsController = TextEditingController(text: '1');

  EventType _selectedType = EventType.saving;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _targetAmountController.dispose();
    _initialDepositController.dispose();
    _participantsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 60)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final targetAmount =
          double.tryParse(_targetAmountController.text.trim()) ?? 0;
      final initialAmount =
          double.tryParse(_initialDepositController.text.trim()) ?? 0;
      final participants =
          int.tryParse(_participantsController.text.trim()) ?? 1;

      final newEvent = FinanceEvent(
        id: 'ev-${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? '${_selectedType.label} milestone'
            : _descController.text.trim(),
        type: _selectedType,
        targetAmount: targetAmount,
        currentAmount: initialAmount,
        targetDate:
            _selectedDate ?? DateTime.now().add(const Duration(days: 90)),
        participants: participants,
        category: _selectedType.label,
      );

      widget.onEventCreated(newEvent);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 38,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText.subtitle(
                    'Create Financial Event',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  IconButton(
                    icon: const FaIcon(
                      FontAwesomeIcons.xmark,
                      color: Color(0xFF64748B),
                      size: 18,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Event Type Selector Chips
              const AppText.paragraph(
                'Event Category',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: EventType.values.map((type) {
                    final isSelected = _selectedType == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              type.icon,
                              size: 13,
                              color:
                                  isSelected ? Colors.white : type.primaryColor,
                            ),
                            const SizedBox(width: 6),
                            AppText.button(
                              type.label,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF334155),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        selected: isSelected,
                        selectedColor: type.primaryColor,
                        backgroundColor: type.backgroundColor,
                        side: BorderSide(
                          color: isSelected
                              ? type.primaryColor
                              : const Color(0xFFE2E8F0),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedType = type;
                              if (type == EventType.groupSavings &&
                                  _participantsController.text == '1') {
                                _participantsController.text = '4';
                              }
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Event Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Event Name',
                  hintText: 'e.g. Dream Holiday, Car Downpayment',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: FaIcon(
                      FontAwesomeIcons.penToSquare,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter an event name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Target & Initial Amount Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _targetAmountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Target Amount',
                        prefixText: '\$ ',
                        hintText: '5000',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Enter target';
                        }
                        if (double.tryParse(val.trim()) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _initialDepositController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Starting Balance',
                        prefixText: '\$ ',
                        hintText: '0',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Date picker & participants
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.calendarDay,
                              size: 15,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AppText.paragraph(
                                _selectedDate == null
                                    ? 'Target Date'
                                    : DateFormat('MMM dd, yyyy')
                                        .format(_selectedDate!),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _selectedDate == null
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_selectedType == EventType.groupSavings) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _participantsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Members',
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: FaIcon(
                              FontAwesomeIcons.userGroup,
                              size: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Description
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes / Description (Optional)',
                  hintText: 'Add budget notes, details or motivation...',
                ),
              ),

              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0060E6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const AppText.button(
                    'Create Event',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
