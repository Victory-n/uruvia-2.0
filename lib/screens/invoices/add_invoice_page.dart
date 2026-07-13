import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:uruvia/screens/invoices/invoice_preview_page.dart';
import 'package:uruvia/screens/invoices/model/invoice_model.dart';
import '../../constants/colors.dart';
import '../../widgets/custom_text.dart';

class AddInvoicePage extends StatefulWidget {
  const AddInvoicePage({super.key});

  @override
  State<AddInvoicePage> createState() => _AddInvoicePageState();
}

class _InvoiceItemState {
  final TextEditingController descController;
  final TextEditingController priceController;
  int quantity;

  _InvoiceItemState({
    required String description,
    required double price,
    required this.quantity,
  }) : descController = TextEditingController(text: description),
       priceController = TextEditingController(text: price.toStringAsFixed(0));

  void dispose() {
    descController.dispose();
    priceController.dispose();
  }
}

class _AddInvoicePageState extends State<AddInvoicePage> {
  // General Controllers
  late final TextEditingController _invoiceNumberController;
  late final TextEditingController _customerNameController;
  late final TextEditingController _customerEmailController;
  late final TextEditingController _customerPhoneController;
  late final TextEditingController _bankNameController;
  late final TextEditingController _accountNumberController;
  late final TextEditingController _accountNameController;
  late final TextEditingController _taxController;
  late final TextEditingController _discountController;

  // Dates
  DateTime _invoiceDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 14));

  // Items
  final List<_InvoiceItemState> _items = [];

  @override
  void initState() {
    super.initState();
    // Unique invoice number generation
    final randId = DateTime.now().millisecondsSinceEpoch.toString().substring(
      8,
    );
    _invoiceNumberController = TextEditingController(text: "#INV-$randId");

    _customerNameController = TextEditingController();
    _customerEmailController = TextEditingController();
    _customerPhoneController = TextEditingController();

    _bankNameController = TextEditingController(text: "MoniePoint");
    _accountNumberController = TextEditingController(text: "8029130533");
    _accountNameController = TextEditingController(text: "Ndukwe Victory");

    _taxController = TextEditingController(text: "0.0");
    _discountController = TextEditingController(text: "0.0");

    // Add default item
    _items.add(
      _InvoiceItemState(
        description: "Consulting Services",
        price: 3200.0,
        quantity: 1,
      ),
    );
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _customerNameController.dispose();
    _customerEmailController.dispose();
    _customerPhoneController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    _taxController.dispose();
    _discountController.dispose();
    for (var item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  double get subtotal {
    return _items.fold(0.0, (sum, item) {
      final price = double.tryParse(item.priceController.text) ?? 0.0;
      return sum + (item.quantity * price);
    });
  }

  double get taxRate => double.tryParse(_taxController.text) ?? 0.0;
  double get taxAmount => subtotal * (taxRate / 100.0);
  double get discountAmount => double.tryParse(_discountController.text) ?? 0.0;
  double get total => subtotal + taxAmount - discountAmount;

  // Select Date
  Future<void> _selectDate(BuildContext context, bool isInvoiceDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isInvoiceDate ? _invoiceDate : _dueDate,
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

    if (picked != null) {
      setState(() {
        if (isInvoiceDate) {
          _invoiceDate = picked;
          // Auto shift due date if it's before invoice date
          if (_dueDate.isBefore(_invoiceDate)) {
            _dueDate = _invoiceDate.add(const Duration(days: 14));
          }
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  // Helper for quick load customer
  void _quickLoadCustomer(String name, String email, String phone) {
    setState(() {
      _customerNameController.text = name;
      _customerEmailController.text = email;
      _customerPhoneController.text = phone;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: googleSansText(
          text: "Loaded client: $name",
          colors: Colors.white,
          fontWeight: FontWeight.normal,
          size: 14.0,
        ),
        backgroundColor: ConstantColor.blueBackground,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // Build the compiled Invoice model
  Invoice _compileInvoice() {
    final List<InvoiceItem> compiledItems = _items.map((stateItem) {
      return InvoiceItem(
        description: stateItem.descController.text.trim().isEmpty
            ? "Item Description"
            : stateItem.descController.text.trim(),
        quantity: stateItem.quantity,
        unitPrice: double.tryParse(stateItem.priceController.text) ?? 0.0,
      );
    }).toList();

    return Invoice(
      invoiceNumber: _invoiceNumberController.text.trim().isEmpty
          ? "#INV-TEMP"
          : _invoiceNumberController.text.trim(),
      invoiceDate: _invoiceDate,
      dueDate: _dueDate,
      customerName: _customerNameController.text.trim().isEmpty
          ? "Unnamed Client"
          : _customerNameController.text.trim(),
      customerEmail: _customerEmailController.text.trim().isEmpty
          ? "client@email.com"
          : _customerEmailController.text.trim(),
      customerPhone: _customerPhoneController.text.trim().isEmpty
          ? "+234 000 0000"
          : _customerPhoneController.text.trim(),
      items: compiledItems,
      taxRate: taxRate,
      discount: discountAmount,
      bankName: _bankNameController.text.trim().isEmpty
          ? "MoniePoint"
          : _bankNameController.text.trim(),
      accountNumber: _accountNumberController.text.trim().isEmpty
          ? "8029130533"
          : _accountNumberController.text.trim(),
      accountName: _accountNameController.text.trim().isEmpty
          ? "Ndukwe Victory"
          : _accountNameController.text.trim(),
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
        // border: const Border(
        //   bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1.0),
        // ),
        title: interText(
          text: "New Invoice",
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
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: googleSansText(
                    text: "Uploading and Syncing Invoice...",
                    colors: Colors.white,
                    fontWeight: FontWeight.normal,
                    size: 14.0,
                  ),
                  backgroundColor: ConstantColor.blueBackground,
                ),
              );
            },
            icon: Platform.isAndroid
                ? const Icon(
                    Icons.cloud_done_outlined,
                    color: ConstantColor.blueBackground,
                  )
                : const Icon(
                    CupertinoIcons.cloud_upload,
                    color: ConstantColor.blueBackground,
                  ),
          ),
        ],
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
                // Section: Invoice info
                _buildCard(
                  title: "INVOICE DETAILS",
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _invoiceNumberController,
                        label: "Invoice Number",
                        hint: "#INV-0000",
                        icon: CupertinoIcons.number,
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateButton(
                              label: "Issue Date",
                              date: _invoiceDate,
                              onTap: () => _selectDate(context, true),
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: _buildDateButton(
                              label: "Due Date",
                              date: _dueDate,
                              onTap: () => _selectDate(context, false),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                // Section: Customer Info
                _buildCard(
                  title: "CUSTOMER DETAILS",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _customerNameController,
                        label: "Customer Name",
                        hint: "Enter client name",
                        icon: CupertinoIcons.person,
                      ),
                      const SizedBox(height: 12.0),
                      _buildTextField(
                        controller: _customerEmailController,
                        label: "Customer Email",
                        hint: "client@company.com",
                        icon: CupertinoIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12.0),
                      _buildTextField(
                        controller: _customerPhoneController,
                        label: "Customer Phone",
                        hint: "+234 ...",
                        icon: CupertinoIcons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16.0),
                      googleSansText(
                        text: "QUICK PICK FROM DIRECTORY",
                        colors: ConstantColor.paragraphTextSecondary,
                        fontWeight: FontWeight.bold,
                        size: 11.0,
                      ),
                      const SizedBox(height: 8.0),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          _buildQuickPickChip(
                            label: "Tech Corp",
                            onTap: () => _quickLoadCustomer(
                              "Tech Corp Solutions",
                              "contact@techcorp.com",
                              "+234 812 345 6789",
                            ),
                          ),
                          _buildQuickPickChip(
                            label: "Banana Bread",
                            onTap: () => _quickLoadCustomer(
                              "720_bananabread",
                              "business@email.com",
                              "+234 567 890 4745",
                            ),
                          ),
                          _buildQuickPickChip(
                            label: "Ndukwe V.",
                            onTap: () => _quickLoadCustomer(
                              "Ndukwe Victory",
                              "victory@uruvia.app",
                              "+234 902 444 5555",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                // Section: Line Items
                Container(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 14.0,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF2F6FE),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            topRight: Radius.circular(16.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            googleSansText(
                              text: "LINE ITEMS",
                              colors: ConstantColor.blueBackground,
                              fontWeight: FontWeight.bold,
                              size: 12.0,
                            ),
                            googleSansText(
                              text:
                                  "${_items.length} ${_items.length == 1 ? 'item' : 'items'}",
                              colors: ConstantColor.blueBackground,
                              fontWeight: FontWeight.bold,
                              size: 12.0,
                            ),
                          ],
                        ),
                      ),

                      // Items List Builder
                      ..._items.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        final itemTotal =
                            item.quantity *
                            (double.tryParse(item.priceController.text) ?? 0.0);

                        return Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: const Color(0xFFEEEEEE),
                                width: idx == _items.length - 1 ? 0 : 1.0,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: item.descController,
                                      style: const TextStyle(
                                        fontFamily: "googleSans",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                        color: ConstantColor.headingTextPrimary,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: "Item name / description",
                                        hintStyle: TextStyle(
                                          color: ConstantColor
                                              .paragraphTextSecondary,
                                          fontSize: 16.0,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                  if (_items.length > 1)
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          item.dispose();
                                          _items.removeAt(idx);
                                        });
                                      },
                                      icon: const Icon(
                                        CupertinoIcons.trash,
                                        color: Colors.redAccent,
                                        size: 18.0,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Unit Price Editable
                                  Row(
                                    children: [
                                      googleSansText(
                                        text: "₦ ",
                                        colors:
                                            ConstantColor.paragraphTextPrimary,
                                        fontWeight: FontWeight.bold,
                                        size: 16.0,
                                      ),
                                      SizedBox(
                                        width: 90,
                                        child: TextField(
                                          controller: item.priceController,
                                          keyboardType: TextInputType.number,
                                          style: const TextStyle(
                                            fontFamily: "googleSans",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                            color: ConstantColor
                                                .headingTextPrimary,
                                          ),
                                          decoration: const InputDecoration(
                                            hintText: "0",
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          onChanged: (_) => setState(() {}),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Quantity Counter
                                  Row(
                                    children: [
                                      _buildCounterButton(
                                        icon: CupertinoIcons.minus,
                                        onTap: () {
                                          if (item.quantity > 1) {
                                            setState(() {
                                              item.quantity--;
                                            });
                                          }
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0,
                                        ),
                                        child: googleSansText(
                                          text: "${item.quantity}",
                                          colors:
                                              ConstantColor.headingTextPrimary,
                                          fontWeight: FontWeight.bold,
                                          size: 16.0,
                                        ),
                                      ),
                                      _buildCounterButton(
                                        icon: CupertinoIcons.add,
                                        onTap: () {
                                          setState(() {
                                            item.quantity++;
                                          });
                                        },
                                      ),
                                    ],
                                  ),

                                  // Subtotal Item Price
                                  googleSansText(
                                    text: "₦${formatCurrency(itemTotal)}",
                                    colors: ConstantColor.blueBackground,
                                    fontWeight: FontWeight.bold,
                                    size: 16.0,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),

                      // Add Item Text Button
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _items.add(
                                _InvoiceItemState(
                                  description: "",
                                  price: 1000.0,
                                  quantity: 1,
                                ),
                              );
                            });
                          },
                          borderRadius: BorderRadius.circular(10.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: ConstantColor.blueBackground.withOpacity(
                                  0.3,
                                ),
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                              color: ConstantColor.blueBackground.withOpacity(
                                0.04,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  CupertinoIcons.plus_circle,
                                  color: ConstantColor.blueBackground,
                                  size: 18.0,
                                ),
                                const SizedBox(width: 8.0),
                                googleSansText(
                                  text: "Add Line Item",
                                  colors: ConstantColor.blueBackground,
                                  fontWeight: FontWeight.bold,
                                  size: 16.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                // Section: Adjustments (Tax & Discount)
                _buildCard(
                  title: "TAX & DISCOUNT",
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _taxController,
                          label: "Tax Rate (%)",
                          hint: "0.0",
                          icon: CupertinoIcons.percent,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: _buildTextField(
                          controller: _discountController,
                          label: "Discount (₦)",
                          hint: "0.00",
                          icon: CupertinoIcons.minus_circle,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                // Section: Payment Details
                _buildCard(
                  title: "PAYMENT INSTRUCTIONS",
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _bankNameController,
                        label: "Bank Name",
                        hint: "e.g. MoniePoint",
                        icon: CupertinoIcons.house,
                      ),
                      const SizedBox(height: 12.0),
                      _buildTextField(
                        controller: _accountNumberController,
                        label: "Account Number",
                        hint: "10-digit number",
                        icon: CupertinoIcons.creditcard,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12.0),
                      _buildTextField(
                        controller: _accountNameController,
                        label: "Account Name",
                        hint: "Enter receiving name",
                        icon: CupertinoIcons.person_crop_rectangle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),

                // Section: Summary Calculation Panel
                Container(
                  padding: const EdgeInsets.all(18.0),
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
                      _buildSummaryRow(
                        "Subtotal",
                        "₦${formatCurrency(subtotal)}",
                        isBold: false,
                      ),
                      const SizedBox(height: 8.0),
                      _buildSummaryRow(
                        "Tax ($taxRate%)",
                        "₦${formatCurrency(taxAmount)}",
                        isBold: false,
                      ),
                      const SizedBox(height: 8.0),
                      _buildSummaryRow(
                        "Discount",
                        "- ₦${formatCurrency(discountAmount)}",
                        isBold: false,
                        color: Colors.redAccent,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Divider(color: Color(0xFFEEEEEE), height: 1.0),
                      ),
                      _buildSummaryRow(
                        "Total Amount Due",
                        "₦${formatCurrency(total)}",
                        isBold: true,
                        size: 20.0,
                        color: ConstantColor.blueBackground,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30.0),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Mock save as draft
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: googleSansText(
                                text: "Draft saved locally!",
                                colors: Colors.white,
                                fontWeight: FontWeight.normal,
                                size: 14.0,
                              ),
                              backgroundColor: Colors.black87,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: Colors.white,
                          foregroundColor: ConstantColor.blueBackground,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: const BorderSide(
                              color: ConstantColor.blueBackground,
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Platform.isAndroid
                                  ? Icons.save_outlined
                                  : CupertinoIcons.square_arrow_down,
                              size: 18.0,
                            ),
                            const SizedBox(width: 8.0),
                            googleSansText(
                              text: "Save Draft",
                              colors: ConstantColor.blueBackground,
                              fontWeight: FontWeight.bold,
                              size: 16.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final invoice = _compileInvoice();
                          slideRightWidget(
                            newPage: InvoicePreviewPage(invoice: invoice),
                            context: context,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: ConstantColor.blueBackground,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              CupertinoIcons.eye,
                              color: Colors.white,
                              size: 18.0,
                            ),
                            const SizedBox(width: 8.0),
                            googleSansText(
                              text: "Preview",
                              colors: Colors.white,
                              fontWeight: FontWeight.bold,
                              size: 16.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Card wrapper helper
  Widget _buildCard({required String title, required Widget child}) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          googleSansText(
            text: title,
            colors: ConstantColor.paragraphTextSecondary,
            fontWeight: FontWeight.bold,
            size: 12.0,
          ),
          const SizedBox(height: 14.0),
          child,
        ],
      ),
    );
  }

  // Text field helper
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
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
        keyboardType: keyboardType,
        onChanged: onChanged,
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

  // Date selection button helper
  Widget _buildDateButton({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
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
                    text: label,
                    colors: ConstantColor.paragraphTextSecondary,
                    fontWeight: FontWeight.normal,
                    size: 11.0,
                  ),
                  const SizedBox(height: 2.0),
                  googleSansText(
                    text: formatDate(date),
                    colors: ConstantColor.headingTextPrimary,
                    fontWeight: FontWeight.bold,
                    size: 14.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Counter button helper
  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 28.0,
      height: 28.0,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: 14.0, color: ConstantColor.headingTextPrimary),
        padding: EdgeInsets.zero,
      ),
    );
  }

  // Quick pick pill chip helper
  Widget _buildQuickPickChip({
    required String label,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      onPressed: onTap,
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFFDDE0E6)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      label: googleSansText(
        text: label,
        colors: ConstantColor.blueBackground,
        fontWeight: FontWeight.w600,
        size: 12.0,
      ),
    );
  }

  // Summary list row helper
  Widget _buildSummaryRow(
    String label,
    String value, {
    required bool isBold,
    double size = 15.0,
    Color color = ConstantColor.headingTextPrimary,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        googleSansText(
          text: label,
          colors: isBold
              ? ConstantColor.headingTextPrimary
              : ConstantColor.paragraphTextSecondary,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          size: size,
        ),
        googleSansText(
          text: value,
          colors: color,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          size: size,
        ),
      ],
    );
  }
}
