// lib/services/storage_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/item_model.dart';
import '../models/shopping_item_model.dart';
import '../models/item_change_log_model.dart';
import '../models/log_retention_option.dart';

class StorageService {
  static const String _dbName = 'home_orders.db';
  static const int _dbVersion = 1;
  
  // Tables
  static const String _tableName = 'items';
  static const String _shoppingItemsTableName = 'shopping_items';
  static const String _itemChangeLogsTableName = 'item_change_logs';

  // SharedPreferences Keys
  static const String _hasSeededKey = 'has_seeded_default_items';
  static const String _languageCodeKey = 'language_code';
  static const String _logRetentionOptionKey = 'log_retention_option';
  static const String _logRetentionCustomDaysKey = 'log_retention_custom_days';

  Database? _db;

  // ─────────────────────────────────────────────────────────────────────────────
  // Initialization & Lifecycle
  // ─────────────────────────────────────────────────────────────────────────────

  /// Initializes the database connection. Must be called before any CRUD operations.
  Future<void> init() async {
    _db = await _openDatabase();
  }

  /// Opens the database and defines the schema creation logic.
  Future<Database> _openDatabase() async {
    final dbPath = await getDatabasesPath();
    final fullPath = p.join(dbPath, _dbName);

    return openDatabase(
      fullPath,
      version: _dbVersion,
      onCreate: _onCreateDatabase,
    );
  }

  /// Creates the necessary tables and indexes when the database is first created.
  Future<void> _onCreateDatabase(Database db, int version) async {
    final batch = db.batch();

    batch.execute('''
      CREATE TABLE $_tableName (
        id                  TEXT PRIMARY KEY,
        name                TEXT NOT NULL,
        quantityDescription TEXT NOT NULL DEFAULT '',
        expectedDays        INTEGER NOT NULL,
        createdAt           TEXT NOT NULL,
        notificationsEnabled INTEGER NOT NULL DEFAULT 1,
        warningThresholdDays INTEGER NOT NULL DEFAULT 10,
        urgentThresholdDays INTEGER NOT NULL DEFAULT 3,
        lastRefreshedAt     TEXT,
        notes               TEXT
      )
    ''');

    batch.execute('''
      CREATE TABLE $_shoppingItemsTableName (
        id                  INTEGER PRIMARY KEY AUTOINCREMENT,
        title               TEXT NOT NULL,
        inventory_item_id   TEXT,
        is_checked          INTEGER NOT NULL DEFAULT 0,
        price               REAL,
        created_at          INTEGER NOT NULL
      )
    ''');

    batch.execute('''
      CREATE TABLE $_itemChangeLogsTableName (
        id                  INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id             TEXT NOT NULL,
        action_type         TEXT NOT NULL,
        timestamp           TEXT NOT NULL,
        previous_state      TEXT,
        new_state           TEXT,
        description         TEXT
      )
    ''');

    // Indexes for performance optimization
    batch.execute('CREATE INDEX IF NOT EXISTS idx_items_created_at ON $_tableName(createdAt)');
    batch.execute('CREATE INDEX IF NOT EXISTS idx_shopping_items_created_at ON $_shoppingItemsTableName(created_at)');
    batch.execute('CREATE INDEX IF NOT EXISTS idx_shopping_items_inventory_item_id ON $_shoppingItemsTableName(inventory_item_id)');
    batch.execute('CREATE INDEX IF NOT EXISTS idx_change_logs_item_id ON $_itemChangeLogsTableName(item_id)');

    await batch.commit(noResult: true);
  }

  /// Getter for the active database instance. Throws an error if not initialized.
  Database get _database {
    if (_db == null) {
      throw StateError('StorageService not initialised. Call init() first.');
    }
    return _db!;
  }

  /// Closes the current database connection.
  /// Must be called before replacing the database file during restore.
  Future<void> closeDatabase() async {
    try {
      await _db?.close();
    } finally {
      _db = null;
    }
  }

  /// Reopens the database connection after it was closed.
  /// Called after a successful restore operation.
  Future<void> reopenDatabase() async {
    _db = await _openDatabase();
  }

  /// Forces all WAL (Write-Ahead Log) changes to be merged into the main
  /// database file. Ensures a backup taken immediately afterwards contains latest data.
  Future<void> checkpointDatabase() async {
    if (_db != null && _db!.isOpen) {
      await _db!.rawQuery('PRAGMA wal_checkpoint(TRUNCATE)');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Seeding Default Data
  // ─────────────────────────────────────────────────────────────────────────────

  /// Seeds the database with default items on first launch.
  Future<void> seedDefaultData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    final bool hasSeeded = prefs.getBool(_hasSeededKey) ?? false;
    if (hasSeeded) return;

    final String langCode = prefs.getString(_languageCodeKey) ?? 'ar';
    
    final defaultInventoryItems = _getDefaultInventoryItems(langCode);
    final defaultShoppingItems = _getDefaultShoppingItems(langCode);

    final batch = _database.batch();

    for (final item in defaultInventoryItems) {
      batch.insert(_tableName, item.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    for (final shoppingItem in defaultShoppingItems) {
      batch.insert(_shoppingItemsTableName, shoppingItem.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    await batch.commit(noResult: true);
    await prefs.setBool(_hasSeededKey, true);
  }

  /// Generates default inventory items based on language code.
  List<ItemModel> _getDefaultInventoryItems(String langCode) {
    final isArabic = langCode == 'ar';
    final now = DateTime.now();

    return [
      ItemModel(
        id: 'default_rice',
        name: isArabic ? 'ارز' : 'Rice',
        quantityDescription: isArabic ? 'كيس 10 كيلو' : '10kg bag',
        expectedDays: 18,
        createdAt: now.subtract(const Duration(days: 16)),
        lastRefreshedAt: now.subtract(const Duration(days: 16)),
        warningThresholdDays: 5,
        urgentThresholdDays: 2,
        notes: isArabic
            ? 'يمكنك كتابة أي ملاحظة تفيدك لاحقًا، مثل:\n"كيس 10 كيلو يبقى لدي عادة 18 يوم."'
            : 'You can write any note that helps later, such as:\n"I usually have a 10kg bag last 18 days."',
      ),
      ItemModel(
        id: 'default_eggs',
        name: isArabic ? 'بيض' : 'Eggs',
        quantityDescription: isArabic ? 'كرتونة 30 بيضة' : 'carton of 30 eggs',
        expectedDays: 14,
        createdAt: now.subtract(const Duration(days: 10)),
        lastRefreshedAt: now.subtract(const Duration(days: 10)),
        warningThresholdDays: 4,
        urgentThresholdDays: 2,
        notes: isArabic
            ? 'يمكنك كتابة أي ملاحظة تفيدك لاحقًا، مثل:\n"كرتونة 30 بيضة تكفيني عادة 14 يوم."'
            : 'You can write any note that helps later, such as:\n"A carton of 30 eggs usually lasts me 14 days."',
      ),
      ItemModel(
        id: 'default_sugar',
        name: isArabic ? 'سكر' : 'Sugar',
        quantityDescription: isArabic ? 'كيس 5 كيلو' : '5kg bag',
        expectedDays: 14,
        createdAt: now.subtract(const Duration(days: 4)),
        lastRefreshedAt: now.subtract(const Duration(days: 4)),
        warningThresholdDays: 7,
        urgentThresholdDays: 2,
        notes: isArabic
            ? 'يمكنك كتابة أي ملاحظة تفيدك لاحقًا، مثل:\n"كيس 5 كيلو يكفيني عادة 14 يوم."'
            : 'You can write any note that helps later, such as:\n"A 5kg bag usually lasts me 14 days."',
      ),
    ];
  }

  /// Generates default shopping list items based on language code.
  List<ShoppingItem> _getDefaultShoppingItems(String langCode) {
    final isArabic = langCode == 'ar';
    final now = DateTime.now();

    return [
      ShoppingItem(
        title: isArabic ? 'حليب طازج' : 'Fresh Milk',
        isChecked: false,
        price: 6.5,
        createdAt: now,
      ),
      ShoppingItem(
        title: isArabic ? 'بيض' : 'Eggs',
        inventoryItemId: 'default_eggs',
        isChecked: false,
        price: 18.0,
        createdAt: now,
      ),
      ShoppingItem(
        title: isArabic ? 'خبز' : 'Bread',
        isChecked: true,
        price: 2.0,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
    ];
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // CRUD: Inventory Items
  // ─────────────────────────────────────────────────────────────────────────────

  /// Retrieves all inventory items, sorted by remaining days ascending.
  Future<List<ItemModel>> getAllItems() async {
    final rows = await _database.query(_tableName, orderBy: 'createdAt ASC');
    
    final items = rows.map(ItemModel.fromMap).toList()
      ..sort((a, b) => a.remainingDays.compareTo(b.remainingDays));
      
    return items;
  }

  /// Saves an inventory item. Replaces if already exists.
  Future<void> saveItem(ItemModel item) async {
    await _database.insert(
      _tableName,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Saves an inventory item and records a change log entry atomically.
  Future<void> saveItemWithLog({
    required ItemModel item,
    required String actionType,
    ItemModel? previousItem,
    String? description,
  }) async {
    await _database.transaction((txn) async {
      ItemModel? oldState = previousItem;
      if (oldState == null && actionType != ItemActionType.create) {
        final rows = await txn.query(_tableName, where: 'id = ?', whereArgs: [item.id]);
        if (rows.isNotEmpty) {
          oldState = ItemModel.fromMap(rows.first);
        }
      }

      await txn.insert(
        _tableName,
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final log = ItemChangeLogModel(
        itemId: item.id,
        actionType: actionType,
        timestamp: DateTime.now().toUtc().toIso8601String(),
        previousState: oldState?.toJson(),
        newState: item.toJson(),
        description: description,
      );

      await txn.insert(_itemChangeLogsTableName, log.toMap());
    });
  }

  /// Deletes an inventory item by its ID.
  Future<void> deleteItem(String id) async {
    await _database.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  /// Deletes an inventory item by ID and records a DELETE change log entry atomically.
  /// Retains change log history even after the item is deleted.
  Future<void> deleteItemWithLog(String id, {String? description}) async {
    await _database.transaction((txn) async {
      ItemModel? oldState;

      // Capture the current item state before deletion.
      final rows = await txn.query(_tableName, where: 'id = ?', whereArgs: [id]);
      if (rows.isNotEmpty) {
        oldState = ItemModel.fromMap(rows.first);
      }

      await txn.delete(_tableName, where: 'id = ?', whereArgs: [id]);

      // Delete linked shopping items
      await txn.delete(
        _shoppingItemsTableName,
        where: 'inventory_item_id = ?',
        whereArgs: [id],
      );

      final log = ItemChangeLogModel(
        itemId: id,
        actionType: ItemActionType.delete,
        timestamp: DateTime.now().toUtc().toIso8601String(),
        previousState: oldState?.toJson(),
        newState: null,
        description: description,
      );

      await txn.insert(_itemChangeLogsTableName, log.toMap());
    });
  }

  /// Fetches the change logs for a given item ID, ordered by timestamp descending.
  Future<List<ItemChangeLogModel>> getItemChangeLogs(String itemId) async {
    final rows = await _database.query(
      _itemChangeLogsTableName,
      where: 'item_id = ?',
      whereArgs: [itemId],
      orderBy: 'timestamp DESC',
    );
    return rows.map(ItemChangeLogModel.fromMap).toList();
  }

  Future<LogRetentionOption> getLogRetentionOption() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_logRetentionOptionKey);
    return LogRetentionOptionX.fromStorageValue(value);
  }

  Future<int?> getLogRetentionCustomDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_logRetentionCustomDaysKey);
  }

  Future<void> setLogRetentionOption(
    LogRetentionOption option, {
    int? customDays,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_logRetentionOptionKey, option.storageValue);
    if (customDays != null) {
      await prefs.setInt(_logRetentionCustomDaysKey, customDays);
    } else {
      await prefs.remove(_logRetentionCustomDaysKey);
    }
  }

  DateTime? calculateLogRetentionCutoff({
    required LogRetentionOption option,
    int? customDays,
    DateTime? referenceDate,
  }) {
    return calculateLogRetentionCutoffDate(
      option: option,
      customDays: customDays,
      referenceDate: referenceDate,
    );
  }

  /// Deletes logs older than the specified cutoff date.
  /// Returns the number of deleted rows directly from SQLite.
  Future<int> deleteLogsOlderThan(DateTime cutoff) async {
    return await _database.delete(
      _itemChangeLogsTableName,
      where: 'timestamp < ?',
      whereArgs: [cutoff.toUtc().toIso8601String()],
    );
  }

  Future<int> runLogRetentionCleanup({DateTime? referenceDate}) async {
    final option = await getLogRetentionOption();
    final customDays = await getLogRetentionCustomDays();
    final cutoff = calculateLogRetentionCutoff(
      option: option,
      customDays: customDays,
      referenceDate: referenceDate,
    );

    if (cutoff == null) return 0;

    return await deleteLogsOlderThan(cutoff);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // CRUD: Shopping Items
  // ─────────────────────────────────────────────────────────────────────────────

  /// Retrieves all shopping list items, sorted by creation date ascending.
  Future<List<ShoppingItem>> getAllShoppingItems() async {
    final rows = await _database.query(_shoppingItemsTableName, orderBy: 'created_at ASC');
    return rows.map(ShoppingItem.fromMap).toList();
  }

  /// Adds a new shopping item to the database.
  Future<ShoppingItem> addShoppingItem(ShoppingItem item) async {
    final id = await _database.insert(_shoppingItemsTableName, item.toMap());
    return item.copyWith(id: id);
  }

  /// Updates an existing shopping item. Throws if the item lacks an ID.
  Future<void> updateShoppingItem(ShoppingItem item) async {
    if (item.id == null) {
      throw ArgumentError(
        'Cannot update an item without an ID. Use addShoppingItem() first.',
      );
    }
    await _database.update(
      _shoppingItemsTableName,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  /// Toggles the checked status of a shopping item.
  Future<void> setShoppingItemChecked(int id, bool isChecked) async {
    await _database.update(
      _shoppingItemsTableName,
      {'is_checked': isChecked ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deletes a specific shopping item by ID.
  Future<void> deleteShoppingItem(int id) async {
    await _database.delete(_shoppingItemsTableName, where: 'id = ?', whereArgs: [id]);
  }

  /// Deletes all shopping list items.
  Future<void> deleteAllShoppingItems() async {
    await _database.delete(_shoppingItemsTableName);
  }

  /// Updates the title in all shopping_list rows linked to the given inventory item.
  /// Ensures shopping list mirrors the source inventory name.
  Future<void> updateShoppingItemTitleForInventoryItem(
    String inventoryItemId,
    String newTitle,
  ) async {
    await _database.update(
      _shoppingItemsTableName,
      {'title': newTitle},
      where: 'inventory_item_id = ?',
      whereArgs: [inventoryItemId],
    );
  }

  /// Deletes all shopping_list rows linked to the given inventory item.
  /// Prevents orphaned references when an inventory item is deleted.
  Future<void> deleteShoppingItemsForInventoryItem(String inventoryItemId) async {
    await _database.delete(
      _shoppingItemsTableName,
      where: 'inventory_item_id = ?',
      whereArgs: [inventoryItemId],
    );
  }

  /// Bulk inserts multiple shopping items efficiently using a batch.
  Future<void> addMultipleShoppingItems(List<ShoppingItem> itemsToInsert) async {
    if (itemsToInsert.isEmpty) return;

    final batch = _database.batch();
    for (final item in itemsToInsert) {
      batch.insert(_shoppingItemsTableName, item.toMap());
    }
    await batch.commit(noResult: true);
  }

  /// Bulk deletes multiple shopping items efficiently using a batch.
  Future<void> deleteMultipleShoppingItems(List<int> ids) async {
    if (ids.isEmpty) return;

    final batch = _database.batch();
    for (final id in ids) {
      batch.delete(_shoppingItemsTableName, where: 'id = ?', whereArgs: [id]);
    }
    await batch.commit(noResult: true);
  }
}