import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final pathString = join(dbPath, 'uruvia_offline.db');

    return await openDatabase(
      pathString,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Create offline actions queue table
    await db.execute('''
      CREATE TABLE offline_actions (
        id TEXT PRIMARY KEY,
        action_type TEXT NOT NULL,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        payload TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // 2. Create cached profiles table
    await db.execute('''
      CREATE TABLE local_profiles (
        id TEXT PRIMARY KEY,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        email TEXT,
        updated_at TEXT NOT NULL
      )
    ''');

    // 3. Create cached inventory_items table
    await db.execute('''
      CREATE TABLE local_inventory_items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        sku TEXT NOT NULL,
        stock INTEGER NOT NULL,
        threshold INTEGER NOT NULL,
        image_url TEXT,
        retail_price REAL,
        supplier TEXT,
        low_stock_alert INTEGER NOT NULL DEFAULT 0, -- SQLite doesn't have native BOOLEAN, use 0/1
        updated_at TEXT NOT NULL
      )
    ''');

    // 4. Create tasks, settings, invoices and expenses tables
    await _createTasksAndSettingsTables(db);
    await _createFinancialTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createTasksAndSettingsTables(db);
    }
    if (oldVersion < 3) {
      await _createFinancialTables(db);
    }
  }

  Future<void> _createFinancialTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS local_invoices (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS local_expenses (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS local_sales (
        id TEXT PRIMARY KEY,
        customer_name TEXT NOT NULL,
        invoice_number TEXT NOT NULL,
        amount REAL NOT NULL,
        date_paid TEXT NOT NULL,
        status TEXT NOT NULL,
        category TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createTasksAndSettingsTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS local_tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        due_date TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        type TEXT NOT NULL,
        related_item_id TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS local_settings (
        key TEXT PRIMARY KEY,
        value INTEGER NOT NULL
      )
    ''');
  }

  // Clear cache helper
  Future<void> clearTable(String tableName) async {
    final db = await database;
    await db.delete(tableName);
  }

  // Clear all local database tables
  Future<void> clearAllData() async {
    final db = await database;
    final tables = [
      'offline_actions',
      'local_profiles',
      'local_inventory_items',
      'local_invoices',
      'local_expenses',
      'local_sales',
      'local_tasks',
      'local_settings',
    ];
    for (final table in tables) {
      await db.delete(table);
    }
  }

  // Insert or replace a row in local cache
  Future<int> cacheUpsert(String tableName, Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(
      tableName,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Query cached table rows
  Future<List<Map<String, dynamic>>> queryCache(String tableName, {String? where, List<dynamic>? whereArgs, String? orderBy}) async {
    final db = await database;
    return await db.query(tableName, where: where, whereArgs: whereArgs, orderBy: orderBy);
  }

  // Delete cached row
  Future<int> deleteCacheRow(String tableName, String id) async {
    final db = await database;
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  // Get a boolean setting from local cache
  Future<bool> getSetting(String key, {bool defaultValue = true}) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'local_settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (result.isEmpty) {
      return defaultValue;
    }
    return result.first['value'] == 1;
  }

  // Set a boolean setting in local cache
  Future<void> setSetting(String key, bool value) async {
    final db = await database;
    await db.insert(
      'local_settings',
      {
        'key': key,
        'value': value ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
