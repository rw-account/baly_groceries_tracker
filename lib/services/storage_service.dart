// lib/services/storage_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/item_model.dart';

class StorageService {
  static const String _dbName = 'home_orders.db';
  static const int _dbVersion = 1;
  static const String _tableName = 'items';

  Database? _db;

  // ─── Init ────────────────────────────────────────────────────────────────────

  Future<void> init() async {
    _db = await _openDatabase();
    await _seedDefaultData();
  }

  /// Opens (or re-uses) the database. Safe to call multiple times.
  static Future<Database> _openDatabase() async {
    final dbPath = await getDatabasesPath();
    final fullPath = p.join(dbPath, _dbName);

    return openDatabase(
      fullPath,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id                  TEXT PRIMARY KEY,
            name                TEXT NOT NULL,
            quantityDescription TEXT NOT NULL DEFAULT '',
            expectedDays        INTEGER NOT NULL,
            createdAt           TEXT NOT NULL,
            notificationsEnabled INTEGER NOT NULL DEFAULT 1,
            safeThresholdDays   INTEGER NOT NULL DEFAULT 20,
            warningThresholdDays INTEGER NOT NULL DEFAULT 10,
            urgentThresholdDays INTEGER NOT NULL DEFAULT 3,
            lastRefreshedAt     TEXT
          )
        ''');
      },
    );
  }

  Database get _database {
    if (_db == null) throw StateError('StorageService not initialised. Call init() first.');
    return _db!;
  }

  // ─── Seed ────────────────────────────────────────────────────────────────────

  Future<void> _seedDefaultData() async {
    final count = Sqflite.firstIntValue(
      await _database.rawQuery('SELECT COUNT(*) FROM $_tableName'),
    );
    if ((count ?? 0) > 0) return;

    final defaults = [
      ItemModel(
        id: 'default_sugar',
        name: 'سكر',
        quantityDescription: 'كيس 5 كيلو',
        expectedDays: 30,
        createdAt: DateTime.now(),
        safeThresholdDays: 20,
        warningThresholdDays: 10,
        urgentThresholdDays: 3,
      ),
      ItemModel(
        id: 'default_flour',
        name: 'دقيق',
        quantityDescription: 'كيس 10 كيلو',
        expectedDays: 45,
        createdAt: DateTime.now(),
        safeThresholdDays: 25,
        warningThresholdDays: 12,
        urgentThresholdDays: 4,
      ),
      ItemModel(
        id: 'default_oil',
        name: 'زيت',
        quantityDescription: 'عبوتان',
        expectedDays: 20,
        createdAt: DateTime.now(),
        safeThresholdDays: 15,
        warningThresholdDays: 7,
        urgentThresholdDays: 2,
      ),
    ];

    final batch = _database.batch();
    for (final item in defaults) {
      batch.insert(_tableName, item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  // ─── CRUD ────────────────────────────────────────────────────────────────────

  Future<List<ItemModel>> getAllItems() async {
    final rows = await _database.query(
      _tableName,
      orderBy: 'createdAt ASC',
    );
    final items = rows.map(ItemModel.fromMap).toList()
      ..sort((a, b) => a.remainingDays.compareTo(b.remainingDays));
    return items;
  }

  Future<void> saveItem(ItemModel item) async {
    await _database.insert(
      _tableName,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteItem(String id) async {
    await _database.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  // ─── Background helper ────────────────────────────────────────────────────────

  /// Opens its own DB connection (for use in background isolates / Workmanager).
  static Future<List<ItemModel>> getAllItemsBackground() async {
    final db = await _openDatabase();
    try {
      final rows = await db.query(_tableName, orderBy: 'createdAt ASC');
      return rows.map(ItemModel.fromMap).toList();
    } finally {
      await db.close();
    }
  }
}
