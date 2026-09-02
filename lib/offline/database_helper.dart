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

    // 2. Create cached user profiles table
    await db.execute('''
      CREATE TABLE local_profiles (
        id TEXT PRIMARY KEY,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        email TEXT,
        currency TEXT NOT NULL DEFAULT 'NGN',
        updated_at TEXT NOT NULL
      )
    ''');

    // 3. Create cached inventory items table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS local_inventory_items (
        id TEXT PRIMARY KEY,
        item_name TEXT,
        category TEXT,
        quantity INTEGER,
        cost_price REAL,
        selling_price REAL,
        low_stock_alert INTEGER,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // 4. Create cached budget plans table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS local_budget_plans (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        title TEXT NOT NULL,
        total_income REAL NOT NULL DEFAULT 0,
        cycle TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        is_business INTEGER NOT NULL DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // 5. Create cached budget category items table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS local_budget_items (
        id TEXT PRIMARY KEY,
        plan_id TEXT NOT NULL,
        category_name TEXT NOT NULL,
        icon_code_point INTEGER NOT NULL,
        allocated_amount REAL NOT NULL DEFAULT 0,
        spent_amount REAL NOT NULL DEFAULT 0,
        soft_stop_threshold REAL NOT NULL DEFAULT 0.8,
        is_hard_stop_enabled INTEGER NOT NULL DEFAULT 0,
        color_value INTEGER NOT NULL,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute("ALTER TABLE local_profiles ADD COLUMN currency TEXT NOT NULL DEFAULT 'NGN';");
      } catch (_) {}
    }
    if (oldVersion < 3) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS local_inventory_items (
            id TEXT PRIMARY KEY,
            item_name TEXT,
            category TEXT,
            quantity INTEGER,
            cost_price REAL,
            selling_price REAL,
            low_stock_alert INTEGER,
            created_at TEXT,
            updated_at TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS local_budget_plans (
            id TEXT PRIMARY KEY,
            user_id TEXT,
            title TEXT NOT NULL,
            total_income REAL NOT NULL DEFAULT 0,
            cycle TEXT NOT NULL,
            start_date TEXT NOT NULL,
            end_date TEXT NOT NULL,
            is_business INTEGER NOT NULL DEFAULT 0,
            created_at TEXT,
            updated_at TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS local_budget_items (
            id TEXT PRIMARY KEY,
            plan_id TEXT NOT NULL,
            category_name TEXT NOT NULL,
            icon_code_point INTEGER NOT NULL,
            allocated_amount REAL NOT NULL DEFAULT 0,
            spent_amount REAL NOT NULL DEFAULT 0,
            soft_stop_threshold REAL NOT NULL DEFAULT 0.8,
            is_hard_stop_enabled INTEGER NOT NULL DEFAULT 0,
            color_value INTEGER NOT NULL,
            created_at TEXT,
            updated_at TEXT
          )
        ''');
      } catch (_) {}
    }
  }

  // Clear cache helper for a specific table
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
      'local_budget_plans',
      'local_budget_items',
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
  Future<List<Map<String, dynamic>>> queryCache(
    String tableName, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    return await db.query(
      tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  // Delete cached row
  Future<int> deleteCacheRow(String tableName, String id) async {
    final db = await database;
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
