import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uruvia/classes/whatsapp/whatsapp_messages.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/screens/invoices/model/invoice_model.dart';
import 'package:uruvia/screens/customer directory/customer_repository.dart';
import 'package:uruvia/screens/customer directory/customer_model.dart';
import 'package:uruvia/widgets/custom_text.dart';
import 'package:uruvia/classes/custom_snackbar.dart';
import 'package:uruvia/services/pdf_invoice_service.dart';

class WhatsAppShareSheet extends StatefulWidget {
  final Invoice invoice;

  const WhatsAppShareSheet({super.key, required this.invoice});

  @override
  State<WhatsAppShareSheet> createState() => _WhatsAppShareSheetState();
}

class _WhatsAppShareSheetState extends State<WhatsAppShareSheet> {
  bool _includePdfAttachment = true;
  int _selectedContactIndex = 0;

  late List<Map<String, String>> _frequentContacts;
  late String _messagePreview;

  @override
  void initState() {
    super.initState();
    final inv = widget.invoice;
    final primaryName = inv.customerName.isNotEmpty
        ? inv.customerName
        : "Client";

    _frequentContacts = [
      {
        'name': primaryName,
        'initials': _getInitials(primaryName),
        'phone': inv.customerPhone,
      },
    ];

    _updateMessagePreview();
    _loadDirectoryContacts();
  }

  Future<void> _loadDirectoryContacts() async {
    final inv = widget.invoice;
    final primaryName = inv.customerName.isNotEmpty
        ? inv.customerName
        : "Client";
    final savedCustomers = await CustomerRepository.instance.getCustomers();

    final List<Map<String, String>> contacts = [
      {
        'name': primaryName,
        'initials': _getInitials(primaryName),
        'phone': inv.customerPhone,
      },
    ];

    for (final c in savedCustomers) {
      if (c.name.toLowerCase() != primaryName.toLowerCase()) {
        contacts.add({
          'name': c.name,
          'initials': c.initials,
          'phone': c.phone,
        });
      }
    }

    if (mounted) {
      setState(() {
        _frequentContacts = contacts;
      });
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return "C";
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  void _updateMessagePreview() {
    final inv = widget.invoice;
    final selectedClient = _frequentContacts[_selectedContactIndex]['name'];
    final bankInfo =
        "${inv.accountNumber} (${inv.accountName.isNotEmpty ? inv.accountName : 'Uruvia User'})";

    setState(() {
      _messagePreview = WhatsAppMessages.invoiceShare(
        invoiceNumber: inv.invoiceNumber,
        amount: inv.total,
        dueDate: inv.dueDate,
        bankDetails: bankInfo,
        clientName: selectedClient,
      );
    });
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _messagePreview));
    if (mounted) {
      CustomSnackbar.showSuccess(context, "Message copied to clipboard!");
    }
  }

  Future<void> _sendViaWhatsApp() async {
    final rawPhone =
        _frequentContacts[_selectedContactIndex]['phone'] ??
        widget.invoice.customerPhone;
    final phone = rawPhone.replaceAll(RegExp(r'[^\d+]'), '');

    if (_includePdfAttachment) {
      try {
        await PdfInvoiceService.shareInvoicePdf(
          widget.invoice,
          text: _messagePreview,
        );
      } catch (e) {
        if (mounted) {
          CustomSnackbar.showFailed(context, "Could not attach PDF: $e");
        }
        await Share.share(
          _messagePreview,
          subject: 'Invoice #${widget.invoice.invoiceNumber}',
        );
      }
    } else {
      // Launch WhatsApp directly via web link if available or fallback to share
      final String encodedText = Uri.encodeComponent(_messagePreview);
      final String urlString = phone.isNotEmpty
          ? "https://wa.me/$phone?text=$encodedText"
          : "https://wa.me/?text=$encodedText";
      final Uri url = Uri.parse(urlString);

      try {
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          await Share.share(_messagePreview);
        }
      } catch (e) {
        await Share.share(_messagePreview);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      padding: EdgeInsets.only(
        top: 12.0,
        left: 20.0,
        right: 20.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle pill
          Center(
            child: Container(
              width: 40.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.share,
                    color: ConstantColor.headingTextPrimary,
                    size: 20.0,
                  ),
                  const SizedBox(width: 10.0),
                  interText(
                    text: "Share Invoice",
                    colors: ConstantColor.headingTextPrimary,
                    fontWeight: FontWeight.bold,
                    size: 20.0,
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  CupertinoIcons.xmark,
                  color: ConstantColor.paragraphTextSecondary,
                  size: 20.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // Message Preview Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF3FF), // Light blue box
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: const Color(0xFFD4E5FF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    googleSansText(
                      text: "MESSAGE PREVIEW",
                      colors: ConstantColor.paragraphTextSecondary,
                      fontWeight: FontWeight.bold,
                      size: 11.0,
                    ),
                    InkWell(
                      onTap: _copyToClipboard,
                      borderRadius: BorderRadius.circular(6.0),
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6.0),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: const Icon(
                          CupertinoIcons.doc_on_doc,
                          size: 14.0,
                          color: ConstantColor.paragraphTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                googleSansText(
                  text: '"$_messagePreview"',
                  colors: ConstantColor.headingTextPrimary,
                  fontWeight: FontWeight.w500,
                  size: 13.5,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),

          // Include PDF Attachment Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  googleSansText(
                    text: "Include PDF Attachment",
                    colors: ConstantColor.headingTextPrimary,
                    fontWeight: FontWeight.bold,
                    size: 15.0,
                  ),
                  const SizedBox(height: 2.0),
                  googleSansText(
                    text: "Attach the generated invoice PDF",
                    colors: ConstantColor.paragraphTextSecondary,
                    fontWeight: FontWeight.normal,
                    size: 12.5,
                  ),
                ],
              ),
              CupertinoSwitch(
                value: _includePdfAttachment,
                activeColor: ConstantColor.blueBackground,
                onChanged: (val) {
                  setState(() {
                    _includePdfAttachment = val;
                  });
                },
              ),
            ],
          ),
          const Divider(height: 32.0, color: Color(0xFFEEEEEE)),

          // Frequent Contacts Section
          googleSansText(
            text: "FREQUENT CONTACTS",
            colors: ConstantColor.paragraphTextSecondary,
            fontWeight: FontWeight.bold,
            size: 11.0,
          ),
          const SizedBox(height: 12.0),
          Row(
            children: _frequentContacts.asMap().entries.map((entry) {
              final idx = entry.key;
              final contact = entry.value;
              final isSelected = _selectedContactIndex == idx;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedContactIndex = idx;
                  });
                  _updateMessagePreview();
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 26.0,
                        backgroundColor: isSelected
                            ? ConstantColor.blueBackground
                            : const Color(0xFFE2E8F0),
                        child: googleSansText(
                          text: contact['initials']!,
                          colors: isSelected
                              ? Colors.white
                              : ConstantColor.headingTextPrimary,
                          fontWeight: FontWeight.bold,
                          size: 14.0,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      googleSansText(
                        text: contact['name']!,
                        colors: isSelected
                            ? ConstantColor.blueBackground
                            : ConstantColor.paragraphTextSecondary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        size: 12.0,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24.0),

          // Send via WhatsApp Button
          SizedBox(
            width: double.infinity,
            height: 52.0,
            child: ElevatedButton.icon(
              onPressed: _sendViaWhatsApp,
              icon: const Icon(
                CupertinoIcons.chat_bubble_2_fill,
                color: Colors.white,
                size: 22.0,
              ),
              label: interText(
                text: "Send via WhatsApp",
                colors: Colors.white,
                fontWeight: FontWeight.bold,
                size: 16.0,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                elevation: 0.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12.0),

          // More Sharing Options Button
          Center(
            child: TextButton(
              onPressed: () {
                if (_includePdfAttachment) {
                  PdfInvoiceService.shareInvoicePdf(
                    widget.invoice,
                    text: _messagePreview,
                  );
                } else {
                  Share.share(_messagePreview);
                }
              },
              child: googleSansText(
                text: "More Sharing Options",
                colors: ConstantColor.paragraphTextPrimary,
                fontWeight: FontWeight.bold,
                size: 14.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
