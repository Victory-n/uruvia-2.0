import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uruvia/offline/database_helper.dart';
import 'package:uruvia/screens/invoices/model/invoice_model.dart';
import 'sales_model.dart';

class SalesRepository {
  static final SalesRepository _instance = SalesRepository._internal();
  static SalesRepository get instance => _instance;
  SalesRepository._internal();

  final List<Sale> _sales = [];

  List<Sale> get sales => List.unmodifiable(_sales);

  Future<List<Sale>> getSales() async {
    try {
      final dbHelper = DatabaseHelper.instance;
      final cachedRows = await dbHelper.queryCache('local_sales');
      if (cachedRows.isNotEmpty) {
        final List<Sale> cachedSales =
            cachedRows.map((row) => Sale.fromMap(row)).toList();
        for (var sale in cachedSales) {
          if (!_sales.any((s) => s.invoiceNumber == sale.invoiceNumber)) {
            _sales.add(sale);
          }
        }
      }

      // Try live Supabase fetch
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await Supabase.instance.client
            .from('sales')
            .select()
            .eq('user_id', user.id);

        for (var row in (response as List)) {
          final sale = Sale(
            id: row['id']?.toString() ?? '',
            customerName: row['customer_name'] ?? 'Client',
            invoiceNumber: row['invoice_number'] ?? '',
            amount: (row['amount'] as num).toDouble(),
            datePaid: row['date_paid'] != null
                ? DateTime.parse(row['date_paid'] as String)
                : DateTime.now(),
            status: row['status'] ?? 'Paid',
            category: row['category'] ?? 'Invoice Payment',
          );
          if (!_sales.any((s) => s.invoiceNumber == sale.invoiceNumber)) {
            _sales.add(sale);
          }
          await dbHelper.cacheUpsert('local_sales', sale.toMap());
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Sales repository query info: $e");
      }
    }
    return sales;
  }

  Future<void> addSaleFromInvoice(Invoice invoice) async {
    // Avoid duplicate sale entry for the same invoice number
    if (_sales.any((s) => s.invoiceNumber == invoice.invoiceNumber)) {
      return;
    }

    final newSale = Sale(
      id: "SALE-${invoice.invoiceNumber.replaceAll('#', '')}",
      customerName: invoice.customerName.isNotEmpty
          ? invoice.customerName
          : "Client",
      invoiceNumber: invoice.invoiceNumber,
      amount: invoice.total,
      datePaid: DateTime.now(),
      status: "Paid",
      category: "Invoice Payment",
    );

    _sales.insert(0, newSale);

    try {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.cacheUpsert('local_sales', newSale.toMap());

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('sales').upsert({
          'id': newSale.id,
          'user_id': user.id,
          'customer_name': newSale.customerName,
          'invoice_number': newSale.invoiceNumber,
          'amount': newSale.amount,
          'date_paid': newSale.datePaid.toIso8601String(),
          'status': newSale.status,
          'category': newSale.category,
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error saving sale record: $e");
      }
    }
  }

  Future<void> addSaleDetails({
    required String customerName,
    required String invoiceNumber,
    required double amount,
    DateTime? datePaid,
  }) async {
    if (_sales.any((s) => s.invoiceNumber == invoiceNumber)) {
      return;
    }

    final newSale = Sale(
      id: "SALE-${invoiceNumber.replaceAll('#', '')}",
      customerName: customerName,
      invoiceNumber: invoiceNumber,
      amount: amount,
      datePaid: datePaid ?? DateTime.now(),
      status: "Paid",
      category: "Invoice Payment",
    );

    _sales.insert(0, newSale);
    try {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.cacheUpsert('local_sales', newSale.toMap());
    } catch (e) {
      if (kDebugMode) {
        print("Error saving local sale details: $e");
      }
    }
  }
}
