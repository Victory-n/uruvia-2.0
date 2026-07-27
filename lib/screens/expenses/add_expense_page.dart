import 'dart:io';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uruvia/classes/show_half_screen.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/screens/invoices/model/invoice_model.dart'; // For formatDate
import 'package:uruvia/widgets/custom_text.dart';
import 'package:uruvia/offline/database_helper.dart';
import 'package:uruvia/screens/tasks/task_model.dart';
import 'package:uruvia/screens/tasks/tasks_repository.dart';
import 'package:uruvia/services/notification_service.dart';
import 'package:uruvia/classes/custom_snackbar.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  late final TextEditingController _amountController;
  late final TextEditingController _vendorController;
  late final TextEditingController _descriptionController;

  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = "Software";

  // Payment Reminder state
  bool _setPaymentReminder = false;
  DateTime _reminderDate = DateTime.now().add(const Duration(days: 1));

  // Receipt upload state
  bool _hasReceipt = false;
  String? _receiptName;
  String _receiptSizeLabel = "";
  File? _receiptFile;
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _categories = [
    "Software",
    "Travel",
    "Meals",
    "Supplies",
    "Rent",
    "Marketing",
    "Other",
  ];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _vendorController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _vendorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Choose date dialog
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ConstantColor.blueBackground,
              onPrimary: Colors.white,
              onSurface: ConstantColor.headingTextPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectReminderDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _reminderDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ConstantColor.blueBackground,
              onPrimary: Colors.white,
              onSurface: ConstantColor.headingTextPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _reminderDate) {
      setState(() {
        _reminderDate = picked;
      });
    }
  }

  // Pick receipt from camera or gallery using image_picker
  Future<void> _pickReceipt(ImageSource source) async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (picked == null) return;
      final file = File(picked.path);
      final sizeBytes = await file.length();
      final sizeMb = (sizeBytes / (1024 * 1024)).toStringAsFixed(1);
      if (mounted) {
        setState(() {
          _receiptFile = file;
          _hasReceipt = true;
          _receiptName = picked.name;
          _receiptSizeLabel = "$sizeMb MB";
        });
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showFailed(context, "Could not pick image: $e");
      }
    }
  }

  // Show bottom sheet picker for receipt
  void _showReceiptPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 16.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                googleSansText(
                  text: "Upload Receipt",
                  colors: ConstantColor.headingTextPrimary,
                  fontWeight: FontWeight.bold,
                  size: 16.0,
                ),
                const SizedBox(height: 16.0),
                ListTile(
                  leading: const Icon(
                    CupertinoIcons.camera,
                    color: ConstantColor.blueBackground,
                  ),
                  title: googleSansText(
                    text: "Take Photo",
                    colors: ConstantColor.headingTextPrimary,
                    fontWeight: FontWeight.bold,
                    size: 14.5,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickReceipt(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    CupertinoIcons.photo,
                    color: ConstantColor.blueBackground,
                  ),
                  title: googleSansText(
                    text: "Choose from Gallery",
                    colors: ConstantColor.headingTextPrimary,
                    fontWeight: FontWeight.bold,
                    size: 14.5,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickReceipt(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveExpense() async {
    final amountText = _amountController.text.trim();
    final vendorText = _vendorController.text.trim();

    if (amountText.isEmpty) {
      CustomSnackbar.showFailed(context, "Please enter an expense amount");
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      CustomSnackbar.showFailed(context, "Please enter a valid expense amount");
      return;
    }

    final vendor = vendorText.isEmpty ? "Generic Merchant" : vendorText;

    if (_setPaymentReminder) {
      final taskId = 'expense_pay_${DateTime.now().millisecondsSinceEpoch}';
      final task = Task(
        id: taskId,
        title: "Pay Expense: $vendor",
        description:
            "Payment of ₦${formatCurrency(amount)} due for $vendor. Notes: ${_descriptionController.text.trim()}",
        dueDate: _reminderDate,
        type: 'expense',
        relatedItemId: taskId,
        createdAt: DateTime.now(),
      );
      await TasksRepository.instance.addTask(task);

      // Schedule morning notification on reminder date (9:00 AM)
      final notificationTime = DateTime(
        _reminderDate.year,
        _reminderDate.month,
        _reminderDate.day,
        9,
        0,
      );
      await NotificationService.instance.scheduleNotification(
        task.id,
        "Expense Reminder: $vendor",
        "Payment of ₦${formatCurrency(amount)} is due today.",
        notificationTime,
      );
    }
    final expenseId = 'exp_${DateTime.now().millisecondsSinceEpoch}';
    final dbHelper = DatabaseHelper.instance;
    final expensePayload = {
      'id': expenseId,
      'amount': amount,
      'status': 'Approved',
      'created_at': _selectedDate.toUtc().toIso8601String(),
      'vendor': vendor,
      'category': _selectedCategory,
    };
    await dbHelper.cacheUpsert('local_expenses', expensePayload);

    // Persist expense to Supabase so dashboard remote sync picks it up
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('expenses').upsert({
          ...expensePayload,
          'user_id': user.id,
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving expense to Supabase: $e');
      }
    }

    // Pop back and show success feedback
    if (mounted) {
      Navigator.pop(context);
      final msg = _hasReceipt
          ? "Recorded expense: ₦${formatCurrency(amount)} at $vendor (Receipt Attached)!"
          : "Recorded expense: ₦${formatCurrency(amount)} at $vendor!";
      CustomSnackbar.showSuccess(context, msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        title: interText(
          text: "Add Expense",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 20.0,
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            CupertinoIcons.chevron_back,
            color: ConstantColor.headingTextPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Amount Input Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10.0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      googleSansText(
                        text: "ENTER AMOUNT",
                        colors: ConstantColor.paragraphTextSecondary,
                        fontWeight: FontWeight.bold,
                        size: 11.0,
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          googleSansText(
                            text: "₦ ",
                            colors: ConstantColor.headingTextPrimary,
                            fontWeight: FontWeight.w900,
                            size: 32.0,
                          ),
                          IntrinsicWidth(
                            child: TextField(
                              controller: _amountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              style: const TextStyle(
                                fontFamily: "googleSans",
                                fontSize: 36.0,
                                color: ConstantColor.headingTextPrimary,
                                fontWeight: FontWeight.w900,
                              ),
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                hintText: "0.00",
                                hintStyle: TextStyle(color: Color(0xFFDDDDDD)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                // 5. Voice Scan Option Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F6FE),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: ConstantColor.blueBackground.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            googleSansText(
                              text: "Scan Receipt by Voice",
                              colors: ConstantColor.blueBackground,
                              fontWeight: FontWeight.bold,
                              size: 15.0,
                            ),
                            const SizedBox(height: 4.0),
                            googleSansText(
                              text:
                                  "Tell Uruvia what you bought and let AI auto-fill the forms.",
                              colors: ConstantColor.paragraphTextSecondary,
                              fontWeight: FontWeight.normal,
                              size: 12.0,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      AvatarGlow(
                        startDelay: const Duration(milliseconds: 1000),
                        glowColor: Colors.blue,
                        glowShape: BoxShape.circle,
                        glowRadiusFactor: 0.15,
                        animate: true,
                        curve: Curves.elasticOut,
                        child: Material(
                          shape: const CircleBorder(),
                          color: Colors.white,
                          elevation: 2.0,
                          child: IconButton(
                            onPressed: () async {
                              final result = await showHalfScreenModal(context);
                              if (result != null && mounted) {
                                setState(() {
                                  if (result['amount'] != null) {
                                    final double amt = result['amount'];
                                    _amountController.text = amt == amt.toInt()
                                        ? amt.toInt().toString()
                                        : amt.toString();
                                  }
                                  if (result['merchant'] != null &&
                                      result['merchant'] !=
                                          'Generic Merchant') {
                                    _vendorController.text = result['merchant'];
                                  }
                                  if (result['description'] != null) {
                                    _descriptionController.text =
                                        result['description'];
                                  }
                                  if (result['category'] != null) {
                                    final cat = result['category'];
                                    if (_categories.contains(cat)) {
                                      _selectedCategory = cat;
                                    }
                                  }
                                });

                                String feedback = "Autofilled: ";
                                final List<String> filled = [];
                                if (result['amount'] != null)
                                  filled.add("Amount (₦${result['amount']})");
                                if (result['description'] != null &&
                                    result['description'].isNotEmpty)
                                  filled.add("Description");
                                if (result['merchant'] != null &&
                                    result['merchant'] != 'Generic Merchant')
                                  filled.add("Merchant");
                                if (result['category'] != null)
                                  filled.add(
                                    "Category (${result['category']})",
                                  );

                                CustomSnackbar.showSuccess(
                                  context,
                                  feedback +
                                      (filled.isEmpty
                                          ? "nothing"
                                          : filled.join(", ")),
                                );
                              }
                            },
                            icon: Icon(
                              Platform.isAndroid
                                  ? Icons.mic
                                  : CupertinoIcons.mic_fill,
                              color: ConstantColor.blueBackground,
                              size: 22.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30.0),

                // 2. Category Selector List
                googleSansText(
                  text: "SELECT CATEGORY",
                  colors: ConstantColor.paragraphTextSecondary,
                  fontWeight: FontWeight.bold,
                  size: 11.0,
                ),
                const SizedBox(height: 8.0),
                SizedBox(
                  height: 40.0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _categories.length,
                    itemBuilder: (context, idx) {
                      final cat = _categories[idx];
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: googleSansText(
                            text: cat,
                            colors: isSelected
                                ? Colors.white
                                : ConstantColor.paragraphTextPrimary,
                            fontWeight: FontWeight.bold,
                            size: 13.0,
                          ),
                          selected: isSelected,
                          selectedColor: ConstantColor.blueBackground,
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: isSelected
                                ? ConstantColor.blueBackground
                                : const Color(0xFFE0E0E0),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16.0),

                // 3. Form Input Details Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10.0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildFormTextField(
                        controller: _vendorController,
                        label: "Merchant / Vendor",
                        hint: "e.g. Uber Technologies",
                        icon: CupertinoIcons.shopping_cart,
                      ),
                      const SizedBox(height: 14.0),
                      _buildFormTextField(
                        controller: _descriptionController,
                        label: "Description / Notes",
                        hint: "e.g. Ride to meeting",
                        icon: CupertinoIcons.doc_text,
                      ),
                      const SizedBox(height: 14.0),
                      // Date Selector Button
                      InkWell(
                        onTap: () => _selectDate(context),
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 10.0,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F8FA),
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: const Color(0xFFE8E9EB)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.calendar,
                                color: ConstantColor.paragraphTextSecondary,
                                size: 18.0,
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    googleSansText(
                                      text: "Expense Date",
                                      colors:
                                          ConstantColor.paragraphTextSecondary,
                                      fontWeight: FontWeight.normal,
                                      size: 11.0,
                                    ),
                                    const SizedBox(height: 2.0),
                                    googleSansText(
                                      text: formatDate(_selectedDate),
                                      colors: ConstantColor.headingTextPrimary,
                                      fontWeight: FontWeight.bold,
                                      size: 14.0,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                CupertinoIcons.chevron_down,
                                color: ConstantColor.paragraphTextSecondary,
                                size: 14.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14.0),
                      // Payment Reminder Toggle Switch
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.bell,
                                color: ConstantColor.paragraphTextSecondary,
                                size: 18.0,
                              ),
                              const SizedBox(width: 8.0),
                              googleSansText(
                                text: "Set Payment Reminder",
                                colors: ConstantColor.headingTextPrimary,
                                fontWeight: FontWeight.bold,
                                size: 14.5,
                              ),
                            ],
                          ),
                          Transform.scale(
                            scale: 0.8,
                            child: CupertinoSwitch(
                              value: _setPaymentReminder,
                              onChanged: (val) {
                                setState(() {
                                  _setPaymentReminder = val;
                                });
                              },
                              activeColor: ConstantColor.blueBackground,
                            ),
                          ),
                        ],
                      ),
                      if (_setPaymentReminder) ...[
                        const SizedBox(height: 14.0),
                        // Reminder Date Selector
                        InkWell(
                          onTap: () => _selectReminderDate(context),
                          borderRadius: BorderRadius.circular(10.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 10.0,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F8FA),
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                color: const Color(0xFFE8E9EB),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.alarm,
                                  color: ConstantColor.paragraphTextSecondary,
                                  size: 18.0,
                                ),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      googleSansText(
                                        text: "Reminder Date",
                                        colors: ConstantColor
                                            .paragraphTextSecondary,
                                        fontWeight: FontWeight.normal,
                                        size: 11.0,
                                      ),
                                      const SizedBox(height: 2.0),
                                      googleSansText(
                                        text: formatDate(_reminderDate),
                                        colors:
                                            ConstantColor.headingTextPrimary,
                                        fontWeight: FontWeight.bold,
                                        size: 14.0,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  CupertinoIcons.chevron_down,
                                  color: ConstantColor.paragraphTextSecondary,
                                  size: 14.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                // 4. ATTACH RECEIPT visual block
                googleSansText(
                  text: "ATTACH RECEIPT",
                  colors: ConstantColor.paragraphTextSecondary,
                  fontWeight: FontWeight.bold,
                  size: 11.0,
                ),
                const SizedBox(height: 8.0),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10.0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: !_hasReceipt
                      ? InkWell(
                          onTap: _showReceiptPicker,
                          borderRadius: BorderRadius.circular(12.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                              color: const Color(0xFFF8FAFC),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  CupertinoIcons.camera_fill,
                                  color: ConstantColor.paragraphTextSecondary,
                                  size: 28.0,
                                ),
                                const SizedBox(height: 8.0),
                                googleSansText(
                                  text: "Upload Receipt Image",
                                  colors: ConstantColor.headingTextPrimary,
                                  fontWeight: FontWeight.bold,
                                  size: 14.0,
                                ),
                                const SizedBox(height: 2.0),
                                googleSansText(
                                  text: "PNG, JPG up to 10MB",
                                  colors: ConstantColor.paragraphTextSecondary,
                                  fontWeight: FontWeight.normal,
                                  size: 11.0,
                                ),
                              ],
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            // Thumbnail if we have a real file, else icon
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: _receiptFile != null
                                  ? Image.file(
                                      _receiptFile!,
                                      width: 56.0,
                                      height: 56.0,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      height: 56.0,
                                      width: 56.0,
                                      color: const Color(0xFFEFF6FF),
                                      child: const Icon(
                                        CupertinoIcons.doc_text_fill,
                                        color: ConstantColor.blueBackground,
                                        size: 24.0,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  googleSansText(
                                    text: _receiptName ?? "receipt.png",
                                    colors: ConstantColor.headingTextPrimary,
                                    fontWeight: FontWeight.bold,
                                    size: 14.0,
                                  ),
                                  const SizedBox(height: 2.0),
                                  googleSansText(
                                    text:
                                        "Ready to upload • $_receiptSizeLabel",
                                    colors: const Color(0xFF2E7D32),
                                    fontWeight: FontWeight.bold,
                                    size: 11.5,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _hasReceipt = false;
                                  _receiptName = null;
                                  _receiptFile = null;
                                  _receiptSizeLabel = "";
                                });
                              },
                              icon: const Icon(
                                CupertinoIcons.trash,
                                color: Colors.redAccent,
                                size: 20.0,
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 16.0),

                // 6. Submit Primary Button
                SizedBox(
                  width: double.infinity,
                  height: 52.0,
                  child: ElevatedButton(
                    onPressed: _saveExpense,
                    style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: ConstantColor.blueBackground,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: googleSansText(
                      text: "Save Expense",
                      colors: Colors.white,
                      fontWeight: FontWeight.bold,
                      size: 16.0,
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Text field helper
  Widget _buildFormTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: const Color(0xFFE8E9EB)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          fontFamily: "googleSans",
          fontSize: 15.0,
          color: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontFamily: "googleSans",
            color: ConstantColor.paragraphTextSecondary,
            fontSize: 13.0,
          ),
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: "googleSans",
            color: Color(0xFFBBBBBB),
            fontSize: 14.0,
          ),
          prefixIcon: Icon(
            icon,
            color: ConstantColor.paragraphTextSecondary,
            size: 18.0,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 6.0),
        ),
      ),
    );
  }
}
