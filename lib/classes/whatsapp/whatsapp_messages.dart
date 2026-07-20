import 'package:uruvia/screens/invoices/model/invoice_model.dart';

class WhatsAppMessages {
  /// Generates a pre-filled WhatsApp message string for sharing an invoice.
  static String invoiceShare({
    required String invoiceNumber,
    required double amount,
    required DateTime dueDate,
    String? bankDetails,
    String? clientName,
  }) {
    final bank = bankDetails ?? "0123456789 (Uruvia User)";
    final formattedAmount = formatCurrency(amount);
    final formattedDate = formatDate(dueDate);
    final greeting = (clientName != null && clientName.trim().isNotEmpty)
        ? "Hello ${clientName.trim()}, "
        : "";

    return '${greeting}Invoice #$invoiceNumber for ₦$formattedAmount is due on $formattedDate. Please find attached. Bank details: $bank.';
  }

  /// Generates a pre-filled WhatsApp message string for an overdue payment reminder.
  static String paymentReminder({
    required String invoiceNumber,
    required double amount,
    required DateTime dueDate,
    String? clientName,
    String? bankDetails,
  }) {
    final bank = bankDetails ?? "0123456789 (Uruvia User)";
    final formattedAmount = formatCurrency(amount);
    final formattedDate = formatDate(dueDate);
    final greeting = (clientName != null && clientName.trim().isNotEmpty)
        ? "Hello ${clientName.trim()}, "
        : "";

    return '${greeting}This is a friendly reminder that Invoice #$invoiceNumber for ₦$formattedAmount was due on $formattedDate. Please make payment to: $bank.';
  }

  /// Generates a pre-filled WhatsApp message string for customer support.
  static String supportInquiry({String? userName}) {
    final name = (userName != null && userName.trim().isNotEmpty)
        ? " from ${userName.trim()}"
        : "";
    return 'Hello Uruvia Support$name, I need assistance with my account.';
  }
}
