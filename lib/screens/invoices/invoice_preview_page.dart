import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uruvia/screens/invoices/model/invoice_model.dart';
import '../../constants/colors.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/whatsapp_share_sheet.dart';
import '../../offline/database_helper.dart';
import '../../screens/tasks/task_model.dart';
import '../../screens/tasks/tasks_repository.dart';
import '../../services/notification_service.dart';
import 'package:uruvia/screens/expenses/sales/sales_repository.dart';
import '../../services/pdf_invoice_service.dart';
import '../../classes/custom_snackbar.dart';

class InvoicePreviewPage extends StatefulWidget {
  final Invoice invoice;

  const InvoicePreviewPage({super.key, required this.invoice});

  @override
  State<InvoicePreviewPage> createState() => _InvoicePreviewPageState();
}

class _InvoicePreviewPageState extends State<InvoicePreviewPage> {
  @override
  void initState() {
    super.initState();
    _scheduleOverdueReminders();
  }

  Future<void> _scheduleOverdueReminders() async {
    try {
      final invoice = widget.invoice;
      if (invoice.status.toLowerCase() == 'paid') return;

      final targetTime = invoice.dueDate.add(const Duration(hours: 24));

      // Schedule notification
      await NotificationService.instance.scheduleNotification(
        invoice.invoiceNumber,
        "Invoice Overdue: ${invoice.invoiceNumber}",
        "Invoice for ${invoice.customerName} of ₦${formatCurrency(invoice.total)} is now overdue.",
        targetTime,
      );

      // If auto create is enabled, add a task with that due date
      final autoCreate = await DatabaseHelper.instance.getSetting(
        'setting_auto_task_overdue_invoice',
        defaultValue: true,
      );
      if (autoCreate) {
        final task = Task(
          id: 'invoice_overdue_${invoice.invoiceNumber}',
          title: "Overdue Invoice: ${invoice.invoiceNumber}",
          description:
              "Follow up with client ${invoice.customerName} on payment of ₦${formatCurrency(invoice.total)}.",
          dueDate: targetTime,
          type: 'invoice',
          relatedItemId: invoice.invoiceNumber,
          createdAt: DateTime.now(),
        );
        await TasksRepository.instance.addTask(task);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Warning: Could not schedule overdue reminder: $e');
      }
    }
  }

  // Mock action helper
  void _showMockActionFeedback(String actionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Row(
          children: [
            const Icon(
              CupertinoIcons.checkmark_seal_fill,
              color: ConstantColor.blueBackground,
              size: 28.0,
            ),
            const SizedBox(width: 8.0),
            googleSansText(
              text: "Success",
              colors: ConstantColor.headingTextPrimary,
              fontWeight: FontWeight.bold,
              size: 20.0,
            ),
          ],
        ),
        content: googleSansText(
          text:
              "Invoice ${widget.invoice.invoiceNumber} has been successfully $actionName!",
          colors: ConstantColor.paragraphTextPrimary,
          fontWeight: FontWeight.normal,
          size: 15.0,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: googleSansText(
              text: "OK",
              colors: ConstantColor.blueBackground,
              fontWeight: FontWeight.bold,
              size: 15.0,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSavePdf() async {
    try {
      final file = await PdfInvoiceService.saveInvoicePdfLocally(
        widget.invoice,
      );
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Row(
            children: [
              const Icon(
                CupertinoIcons.checkmark_seal_fill,
                color: ConstantColor.blueBackground,
                size: 28.0,
              ),
              const SizedBox(width: 8.0),
              googleSansText(
                text: "PDF Saved",
                colors: ConstantColor.headingTextPrimary,
                fontWeight: FontWeight.bold,
                size: 20.0,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              googleSansText(
                text:
                    "Invoice ${widget.invoice.invoiceNumber} has been downloaded and saved as a PDF document.",
                colors: ConstantColor.paragraphTextPrimary,
                fontWeight: FontWeight.normal,
                size: 14.5,
              ),
              const SizedBox(height: 12.0),
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: SelectableText(
                  file.path,
                  style: const TextStyle(
                    fontSize: 12.0,
                    color: ConstantColor.paragraphTextSecondary,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                PdfInvoiceService.shareInvoicePdf(widget.invoice);
              },
              child: googleSansText(
                text: "Share PDF",
                colors: ConstantColor.blueBackground,
                fontWeight: FontWeight.bold,
                size: 15.0,
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: ConstantColor.blueBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: googleSansText(
                text: "Done",
                colors: Colors.white,
                fontWeight: FontWeight.bold,
                size: 15.0,
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.showFailed(context, "Failed to save PDF: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoice = widget.invoice;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        // border: const Border(
        //   bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1.0),
        // ),
        title: interText(
          text: "Invoice Preview",
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
            onPressed: _handleSavePdf,
            icon: Platform.isAndroid
                ? const Icon(
                    Icons.download_rounded,
                    color: ConstantColor.blueBackground,
                  )
                : const Icon(
                    CupertinoIcons.tray_arrow_down,
                    color: ConstantColor.blueBackground,
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // The Physical-Paper-Style Invoice Sheet
              Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15.0,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Logo and Business Info
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: AssetImage("assets/img/logo.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                interText(
                                  text: invoice.businessName,
                                  colors: ConstantColor.headingTextPrimary,
                                  fontWeight: FontWeight.bold,
                                  size: 18.0,
                                ),
                                const SizedBox(height: 4.0),
                                interText(
                                  text: invoice.businessEmail,
                                  colors: ConstantColor.paragraphTextSecondary,
                                  fontWeight: FontWeight.normal,
                                  size: 13.0,
                                ),
                                interText(
                                  text: invoice.businessPhone,
                                  colors: ConstantColor.paragraphTextSecondary,
                                  fontWeight: FontWeight.normal,
                                  size: 13.0,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),

                      // Invoice Number & Status Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              googleSansText(
                                text: "INVOICE",
                                colors: ConstantColor.blueBackground
                                    .withOpacity(0.8),
                                fontWeight: FontWeight.w900,
                                size: 24.0,
                              ),
                              const SizedBox(height: 2.0),
                              interText(
                                text: invoice.invoiceNumber,
                                colors: ConstantColor.headingTextPrimary,
                                fontWeight: FontWeight.bold,
                                size: 14.5,
                              ),
                            ],
                          ),
                          _buildStatusBadge(invoice.status),
                        ],
                      ),
                      const SizedBox(height: 16.0),

                      // Dates Banner
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F8FC),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: const Color(0xFFE3EDFB)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                googleSansText(
                                  text: "INVOICE DATE",
                                  colors: ConstantColor.paragraphTextSecondary,
                                  fontWeight: FontWeight.bold,
                                  size: 10.0,
                                ),
                                const SizedBox(height: 4.0),
                                googleSansText(
                                  text: formatDate(invoice.invoiceDate),
                                  colors: ConstantColor.headingTextPrimary,
                                  fontWeight: FontWeight.bold,
                                  size: 14.0,
                                ),
                              ],
                            ),
                            Container(
                              height: 24.0,
                              width: 1.0,
                              color: const Color(0xFFDDE4EE),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                googleSansText(
                                  text: "DUE DATE",
                                  colors: ConstantColor.paragraphTextSecondary,
                                  fontWeight: FontWeight.bold,
                                  size: 10.0,
                                ),
                                const SizedBox(height: 4.0),
                                googleSansText(
                                  text: formatDate(invoice.dueDate),
                                  colors: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  size: 14.0,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Billed To Details
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          googleSansText(
                            text: "BILLED TO",
                            colors: ConstantColor.paragraphTextSecondary,
                            fontWeight: FontWeight.bold,
                            size: 11.0,
                          ),
                          const SizedBox(height: 6.0),
                          googleSansText(
                            text: invoice.customerName,
                            colors: ConstantColor.headingTextPrimary,
                            fontWeight: FontWeight.bold,
                            size: 16.0,
                          ),
                          if (invoice.customerEmail.isNotEmpty) ...[
                            const SizedBox(height: 2.0),
                            googleSansText(
                              text: invoice.customerEmail,
                              colors: ConstantColor.paragraphTextSecondary,
                              fontWeight: FontWeight.normal,
                              size: 13.0,
                            ),
                          ],
                          if (invoice.customerPhone.isNotEmpty) ...[
                            const SizedBox(height: 2.0),
                            googleSansText(
                              text: invoice.customerPhone,
                              colors: ConstantColor.paragraphTextSecondary,
                              fontWeight: FontWeight.normal,
                              size: 13.0,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24.0),

                      // Line Items Table Header
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              googleSansText(
                                text: "ITEMS & DESCRIPTION",
                                colors: ConstantColor.paragraphTextSecondary,
                                fontWeight: FontWeight.bold,
                                size: 11.0,
                              ),
                              googleSansText(
                                text: "TOTAL",
                                colors: ConstantColor.paragraphTextSecondary,
                                fontWeight: FontWeight.bold,
                                size: 11.0,
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
                            child: Divider(
                              color: Color(0xFFEEEEEE),
                              height: 1.0,
                              thickness: 1.2,
                            ),
                          ),
                        ],
                      ),

                      // Line Items Rows
                      ...invoice.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    googleSansText(
                                      text: item.description,
                                      colors: ConstantColor.headingTextPrimary,
                                      fontWeight: FontWeight.bold,
                                      size: 14.5,
                                    ),
                                    const SizedBox(height: 4.0),
                                    googleSansText(
                                      text:
                                          "Qty ${item.quantity}  ×  ₦${formatCurrency(item.unitPrice)}",
                                      colors:
                                          ConstantColor.paragraphTextSecondary,
                                      fontWeight: FontWeight.w500,
                                      size: 12.5,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              googleSansText(
                                text: "₦${formatCurrency(item.total)}",
                                colors: ConstantColor.headingTextPrimary,
                                fontWeight: FontWeight.bold,
                                size: 14.5,
                              ),
                            ],
                          ),
                        );
                      }),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(
                          color: Color(0xFFEEEEEE),
                          height: 1.0,
                          thickness: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8.0),

                      // Calculation Breakdowns
                      _buildSummaryPreviewRow(
                        "Subtotal",
                        "₦${formatCurrency(invoice.subtotal)}",
                      ),
                      if (invoice.taxRate > 0) ...[
                        const SizedBox(height: 6.0),
                        _buildSummaryPreviewRow(
                          "Tax (${invoice.taxRate}%)",
                          "₦${formatCurrency(invoice.taxAmount)}",
                        ),
                      ],
                      if (invoice.discount > 0) ...[
                        const SizedBox(height: 6.0),
                        _buildSummaryPreviewRow(
                          "Discount",
                          "- ₦${formatCurrency(invoice.discount)}",
                          color: Colors.redAccent,
                        ),
                      ],
                      const SizedBox(height: 16.0),

                      // Balance Due Total Box
                      Container(
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          color: ConstantColor.blueBackground.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: ConstantColor.blueBackground.withOpacity(
                              0.1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            googleSansText(
                              text: "Balance Due",
                              colors: ConstantColor.blueBackground,
                              fontWeight: FontWeight.bold,
                              size: 16.0,
                            ),
                            googleSansText(
                              text: "₦${formatCurrency(invoice.total)}",
                              colors: ConstantColor.blueBackground,
                              fontWeight: FontWeight.w900,
                              size: 18.0,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // Payment Instructions Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF9F6),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: const Color(0xFFF1EFE9)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            googleSansText(
                              text: "PAYMENT INSTRUCTIONS",
                              colors: const Color(0xFF8B7355),
                              fontWeight: FontWeight.bold,
                              size: 10.5,
                            ),
                            const SizedBox(height: 10.0),
                            _buildPaymentRow("Bank Name", invoice.bankName),
                            const SizedBox(height: 6.0),
                            _buildPaymentRow(
                              "Account Number",
                              invoice.accountNumber,
                            ),
                            const SizedBox(height: 6.0),
                            _buildPaymentRow(
                              "Account Name",
                              invoice.accountName,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // Thank you message
                      Center(
                        child: googleSansText(
                          text: "Thank you for your business!",
                          colors: ConstantColor.paragraphTextSecondary,
                          fontWeight: FontWeight.bold,
                          size: 13.0,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12.0),

              // Mark as Paid Action Button
              if (invoice.status.toLowerCase() != 'paid') ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        setState(() {
                          widget.invoice.status = 'Paid';
                        });

                        // Automatically add Paid Invoice as a Sale
                        await SalesRepository.instance.addSaleFromInvoice(
                          widget.invoice,
                        );

                        // Persist the updated invoice status locally
                        final dbHelper = DatabaseHelper.instance;
                        await dbHelper.cacheUpsert('local_invoices', {
                          'id': invoice.invoiceNumber,
                          'amount': invoice.total,
                          'status': 'Paid',
                          'created_at': invoice.invoiceDate
                              .toUtc()
                              .toIso8601String(),
                          'customer_name': invoice.customerName,
                          'due_date': invoice.dueDate.toUtc().toIso8601String(),
                        });

                        // Persist the updated invoice status to Supabase if logged in
                        try {
                          final user =
                              Supabase.instance.client.auth.currentUser;
                          if (user != null) {
                            await Supabase.instance.client
                                .from('invoices')
                                .upsert({
                                  'id': invoice.invoiceNumber,
                                  'user_id': user.id,
                                  'amount': invoice.total,
                                  'status': 'Paid',
                                  'created_at': invoice.invoiceDate
                                      .toUtc()
                                      .toIso8601String(),
                                  'customer_name': invoice.customerName,
                                  'due_date': invoice.dueDate
                                      .toUtc()
                                      .toIso8601String(),
                                });
                          }
                        } catch (e) {
                          if (kDebugMode) {
                            print("Error updating remote invoice status: $e");
                          }
                        }

                        // Cancel Overdue Alerts
                        await NotificationService.instance.cancelNotification(
                          invoice.invoiceNumber,
                        );

                        // Complete Overdue Task
                        final overdueTaskId =
                            'invoice_overdue_${invoice.invoiceNumber}';
                        final overdueTask = Task(
                          id: overdueTaskId,
                          title: "Overdue Invoice: ${invoice.invoiceNumber}",
                          description: "",
                          dueDate: DateTime.now(),
                          isCompleted: true,
                          type: 'invoice',
                          relatedItemId: invoice.invoiceNumber,
                          createdAt: DateTime.now(),
                        );
                        await TasksRepository.instance.updateTask(overdueTask);

                        // Auto-create Sales Fulfillment Task
                        final autoSales = await DatabaseHelper.instance
                            .getSetting(
                              'setting_auto_task_sales_fulfillment',
                              defaultValue: true,
                            );
                        if (autoSales) {
                          final saleTask = Task(
                            id: 'sales_fulfillment_${invoice.invoiceNumber}',
                            title: "Fulfill Order: ${invoice.invoiceNumber}",
                            description:
                                "Prepare and deliver order to client ${invoice.customerName}.",
                            dueDate: DateTime.now().add(
                              const Duration(days: 3),
                            ),
                            type: 'sale',
                            relatedItemId: invoice.invoiceNumber,
                            createdAt: DateTime.now(),
                          );
                          await TasksRepository.instance.addTask(saleTask);

                          // Schedule notification alert for fulfillment reminder
                          await NotificationService.instance
                              .scheduleNotification(
                                saleTask.id,
                                "Fulfillment Warning: ${saleTask.title}",
                                saleTask.description,
                                DateTime.now().add(const Duration(days: 2)),
                              );
                        }

                        _showMockActionFeedback("marked as paid");
                      },
                      icon: const Icon(
                        CupertinoIcons.checkmark_seal_fill,
                        color: Colors.white,
                        size: 20.0,
                      ),
                      label: googleSansText(
                        text: "Mark as Paid",
                        colors: Colors.white,
                        fontWeight: FontWeight.bold,
                        size: 16.0,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32), // Green
                        elevation: 0.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
              ],

              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleSavePdf,
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
                                  ? Icons.save_alt_rounded
                                  : CupertinoIcons.tray_arrow_down,
                              size: 18.0,
                            ),
                            const SizedBox(width: 8.0),
                            googleSansText(
                              text: "Save PDF",
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
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) =>
                                WhatsAppShareSheet(invoice: widget.invoice),
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
                            Icon(
                              Platform.isAndroid
                                  ? Icons.share_rounded
                                  : CupertinoIcons.share,
                              color: Colors.white,
                              size: 18.0,
                            ),
                            const SizedBox(width: 8.0),
                            googleSansText(
                              text: "Share",
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
              ),
              const SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
    );
  }

  // Row helper for calculations in sheet
  Widget _buildSummaryPreviewRow(
    String label,
    String value, {
    Color color = ConstantColor.paragraphTextPrimary,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        googleSansText(
          text: label,
          colors: ConstantColor.paragraphTextSecondary,
          fontWeight: FontWeight.normal,
          size: 14.0,
        ),
        googleSansText(
          text: value,
          colors: color,
          fontWeight: FontWeight.bold,
          size: 14.0,
        ),
      ],
    );
  }

  // Row helper for payment details
  Widget _buildPaymentRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: googleSansText(
            text: label,
            colors: ConstantColor.paragraphTextSecondary,
            fontWeight: FontWeight.w500,
            size: 12.0,
          ),
        ),
        Expanded(
          child: googleSansText(
            text: value,
            colors: ConstantColor.headingTextPrimary,
            fontWeight: FontWeight.bold,
            size: 12.5,
          ),
        ),
      ],
    );
  }

  // Status pill badge generator helper
  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'paid':
        bg = const Color(0xFFE8F5E9);
        text = const Color(0xFF2E7D32);
        icon = CupertinoIcons.checkmark_seal_fill;
        break;
      case 'overdue':
        bg = const Color(0xFFFFEBEE);
        text = const Color(0xFFC62828);
        icon = CupertinoIcons.exclamationmark_shield;
        break;
      case 'draft':
        bg = const Color(0xFFECEFF1);
        text = const Color(0xFF546E7A);
        icon = CupertinoIcons.doc_text_fill;
        break;
      default: // 'sent'
        bg = const Color(0xFFEFF6FF);
        text = ConstantColor.blueBackground;
        icon = CupertinoIcons.paperplane_fill;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: text, size: 12.0),
          const SizedBox(width: 4.0),
          googleSansText(
            text: status.toUpperCase(),
            colors: text,
            fontWeight: FontWeight.bold,
            size: 10.0,
          ),
        ],
      ),
    );
  }
}
