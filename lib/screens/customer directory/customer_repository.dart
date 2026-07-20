import 'package:uruvia/offline/database_helper.dart';
import 'package:uruvia/screens/customer directory/customer_model.dart';

class CustomerRepository {
  static final CustomerRepository _instance = CustomerRepository._internal();
  static CustomerRepository get instance => _instance;
  CustomerRepository._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _tableCreated = false;

  Future<void> _ensureTableExists() async {
    if (_tableCreated) return;
    final db = await _dbHelper.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS local_customers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT,
        company TEXT,
        address TEXT,
        created_at TEXT NOT NULL
      )
    ''');
    _tableCreated = true;
  }

  // Get all saved customers
  Future<List<Customer>> getCustomers() async {
    await _ensureTableExists();
    final List<Map<String, dynamic>> rows = await _dbHelper.queryCache(
      'local_customers',
      orderBy: 'name ASC',
    );
    return rows.map((r) => Customer.fromMap(r)).toList();
  }

  // Add a new customer
  Future<void> addCustomer(Customer customer) async {
    await _ensureTableExists();
    await _dbHelper.cacheUpsert('local_customers', customer.toMap());
  }

  // Update existing customer
  Future<void> updateCustomer(Customer customer) async {
    await _ensureTableExists();
    await _dbHelper.cacheUpsert('local_customers', customer.toMap());
  }

  // Delete customer by ID
  Future<void> deleteCustomer(String id) async {
    await _ensureTableExists();
    await _dbHelper.deleteCacheRow('local_customers', id);
  }
}
