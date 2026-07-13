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
      version: 1,
      onCreate: _onCreate,
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
  }

  // Clear cache helper
  Future<void> clearTable(String tableName) async {
    final db = await database;
    await db.delete(tableName);
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
}
