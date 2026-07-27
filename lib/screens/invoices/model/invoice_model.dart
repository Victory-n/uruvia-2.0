class InvoiceItem {
  String description;
  int quantity;
  double unitPrice;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;
}

class Invoice {
  final String invoiceNumber;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final List<InvoiceItem> items;
  final double taxRate; // in percentage, e.g. 5.0 for 5%
  final double discount; // flat discount amount in NGN

  // Business / Sender details
  final String businessName;
  final String businessEmail;
  final String businessPhone;

  // Banking / Payment details
  final String bankName;
  final String accountNumber;
  final String accountName;
  String status;

  Invoice({
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.dueDate,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.items,
    this.taxRate = 0.0,
    this.discount = 0.0,
    this.businessName = '',
    this.businessEmail = '',
    this.businessPhone = '',
    this.bankName = "MoniePoint",
    this.accountNumber = "8029130533",
    this.accountName = "Ndukwe Victory",
    this.status = "Draft",
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.total);
  double get taxAmount => subtotal * (taxRate / 100.0);
  double get total => subtotal + taxAmount - discount;
}


// Global utilities for formatting in invoice views
String formatCurrency(num amount) {
  String str = amount.toStringAsFixed(2);
  List<String> parts = str.split('.');
  String integerPart = parts[0];
  String decimalPart = parts[1];
  
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  String Function(Match) matchFunc = (Match match) => '${match[1]},';
  integerPart = integerPart.replaceAllMapped(reg, matchFunc);
  
  if (decimalPart == '00') {
    return integerPart;
  }
  return '$integerPart.$decimalPart';
}

String formatDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return "${date.day} ${months[date.month - 1]} ${date.year}";
}
