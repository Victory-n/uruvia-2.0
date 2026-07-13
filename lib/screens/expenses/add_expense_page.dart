import 'dart:io';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uruvia/classes/show_half_screen.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/screens/invoices/model/invoice_model.dart'; // For formatDate
import 'package:uruvia/widgets/custom_text.dart';

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

  // Receipt upload state
  bool _hasReceipt = false;
  String? _receiptName;

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
                    setState(() {
                      _hasReceipt = true;
                      _receiptName = "IMG_receipt_camera.jpg";
                    });
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
                    setState(() {
                      _hasReceipt = true;
                      _receiptName = "receipt_july_12.png";
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _saveExpense() {
    final amountText = _amountController.text.trim();
    final vendorText = _vendorController.text.trim();

    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: googleSansText(
            text: "Please enter an expense amount",
            colors: Colors.white,
            fontWeight: FontWeight.normal,
            size: 14.0,
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: googleSansText(
            text: "Please enter a valid expense amount",
            colors: Colors.white,
            fontWeight: FontWeight.normal,
            size: 14.0,
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final vendor = vendorText.isEmpty ? "Generic Merchant" : vendorText;

    // Pop back and show success feedback
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: googleSansText(
          text: _hasReceipt
              ? "Recorded expense: ₦${formatCurrency(amount)} at $vendor (Receipt Attached)!"
              : "Recorded expense: ₦${formatCurrency(amount)} at $vendor!",
          colors: Colors.white,
          fontWeight: FontWeight.bold,
          size: 14.0,
        ),
        backgroundColor: Colors.green,
      ),
    );
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
                            Container(
                              height: 48.0,
                              width: 48.0,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: const Icon(
                                CupertinoIcons.doc_text_fill,
                                color: ConstantColor.blueBackground,
                                size: 24.0,
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
                                    text: "Ready to upload • 1.2 MB",
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
                            onPressed: () => showHalfScreenModal(context),
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
