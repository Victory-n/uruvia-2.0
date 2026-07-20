import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/screens/invoices/model/invoice_model.dart';
import 'package:uruvia/screens/invoices/invoice_preview_page.dart';
import 'package:uruvia/widgets/custom_text.dart';

class InvoiceCard extends StatelessWidget {
  final String customerName;
  final String invoiceNumber;
  final double amount;
  final DateTime dueDate;
  final String status; // 'Paid', 'Sent', 'Overdue', 'Draft'
  final Invoice? fullInvoice;

  const InvoiceCard({
    super.key,
    required this.customerName,
    required this.invoiceNumber,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.fullInvoice,
  });

  // Initials generator
  String _getInitials(String name) {
    final clean = name.replaceAll(RegExp(r'[^\w\s]'), '').trim();
    final words = clean.split(RegExp(r'\s+'));
    if (words.isEmpty || words[0].isEmpty) return '?';
    if (words.length == 1) {
      return words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  // Theme getter based on Status
  _StatusTheme _getStatusTheme() {
    switch (status.toLowerCase()) {
      case 'paid':
        return const _StatusTheme(
          badgeColor: Color(0xFF2E7D32),
          backgroundColor: Color(0xFFE8F5E9),
          avatarColor: Color(0xFFC8E6C9),
          avatarTextColor: Color(0xFF1B5E20),
          icon: CupertinoIcons.checkmark_seal_fill,
        );
      case 'sent':
      case 'active':
        return const _StatusTheme(
          badgeColor: Color(0xFF0058BE),
          backgroundColor: Color(0xFFEFF4FF),
          avatarColor: Color(0xFFD0E1FD),
          avatarTextColor: Color(0xFF003882),
          icon: CupertinoIcons.paperplane_fill,
        );
      case 'overdue':
        return const _StatusTheme(
          badgeColor: Color(0xFFC62828),
          backgroundColor: Color(0xFFFFEBEE),
          avatarColor: Color(0xFFFFCDD2),
          avatarTextColor: Color(0xFFB71C1C),
          icon: CupertinoIcons.exclamationmark_shield_fill,
        );
      case 'draft':
      default:
        return const _StatusTheme(
          badgeColor: Color(0xFF546E7A),
          backgroundColor: Color(0xFFECEFF1),
          avatarColor: Color(0xFFCFD8DC),
          avatarTextColor: Color(0xFF37474F),
          icon: CupertinoIcons.doc_text_fill,
        );
    }
  }

  // Compile invoice model fallback for preview
  Invoice _compileFallbackInvoice() {
    return Invoice(
      invoiceNumber: invoiceNumber,
      invoiceDate: dueDate.subtract(const Duration(days: 14)),
      dueDate: dueDate,
      customerName: customerName,
      customerEmail: 'client@email.com',
      customerPhone: '',
      items: [
        InvoiceItem(
          description: "Service Item",
          quantity: 1,
          unitPrice: amount,
        ),
      ],
      taxRate: 0.0,
      discount: 0.0,
      status: status,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = _getStatusTheme();
    final initials = _getInitials(customerName);

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final targetInvoice = fullInvoice ?? _compileFallbackInvoice();
            slideRightWidget(
              newPage: InvoicePreviewPage(invoice: targetInvoice),
              context: context,
            );
          },
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Avatar initials, Customer, and Invoice details
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 22.0,
                      backgroundColor: theme.avatarColor,
                      child: googleSansText(
                        text: initials,
                        colors: theme.avatarTextColor,
                        fontWeight: FontWeight.bold,
                        size: 14.0,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          googleSansText(
                            text: customerName,
                            colors: ConstantColor.headingTextPrimary,
                            fontWeight: FontWeight.bold,
                            size: 15.0,
                            softWrap: true,
                          ),
                          const SizedBox(height: 3.0),
                          googleSansText(
                            text: invoiceNumber,
                            colors: ConstantColor.paragraphTextSecondary
                                .withOpacity(0.7),
                            fontWeight: FontWeight.normal,
                            size: 11.5,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        googleSansText(
                          text: "₦${formatCurrency(amount)}",
                          colors: ConstantColor.headingTextPrimary,
                          fontWeight: FontWeight.w900,
                          size: 16.0,
                        ),
                        const SizedBox(height: 3.0),
                        googleSansText(
                          text: "Amount Due",
                          colors: ConstantColor.paragraphTextSecondary
                              .withOpacity(0.8),
                          fontWeight: FontWeight.normal,
                          size: 11.0,
                        ),
                      ],
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(color: Color(0xFFF3F3F5), height: 1.0),
                ),

                // Bottom Row: Status Badge and Due Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status Badge Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 5.0,
                      ),
                      decoration: BoxDecoration(
                        color: theme.backgroundColor,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(theme.icon, color: theme.badgeColor, size: 12.0),
                          const SizedBox(width: 4.0),
                          googleSansText(
                            text: status,
                            colors: theme.badgeColor,
                            fontWeight: FontWeight.bold,
                            size: 11.0,
                          ),
                        ],
                      ),
                    ),

                    // Clickable text / Due date
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.calendar,
                          size: 13.0,
                          color: status.toLowerCase() == 'overdue'
                              ? Colors.redAccent
                              : ConstantColor.paragraphTextSecondary,
                        ),
                        const SizedBox(width: 4.0),
                        googleSansText(
                          text: "Due: ${formatDate(dueDate)}",
                          colors: status.toLowerCase() == 'overdue'
                              ? Colors.redAccent
                              : ConstantColor.paragraphTextSecondary,
                          fontWeight: status.toLowerCase() == 'overdue'
                              ? FontWeight.bold
                              : FontWeight.normal,
                          size: 12.0,
                        ),
                        const SizedBox(width: 4.0),
                        Icon(
                          CupertinoIcons.chevron_right,
                          size: 12.0,
                          color: ConstantColor.paragraphTextSecondary
                              .withOpacity(0.5),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Private status formatting theme class helper
class _StatusTheme {
  final Color badgeColor;
  final Color backgroundColor;
  final Color avatarColor;
  final Color avatarTextColor;
  final IconData icon;

  const _StatusTheme({
    required this.badgeColor,
    required this.backgroundColor,
    required this.avatarColor,
    required this.avatarTextColor,
    required this.icon,
  });
}
