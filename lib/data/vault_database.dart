import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../domain/vault_item.dart';

class VaultDatabase {
  static const int schemaVersion = 2;
  static const String tableVaultItems = 'vault_items';

  final String? overrideDbPath;
  Database? _db;

  VaultDatabase({this.overrideDbPath});

  Future<Database> get database async {
    if (_db != null && _db!.isOpen) return _db!;
    final dbPath =
        overrideDbPath ??
        p.join((await getApplicationSupportDirectory()).path, 'sli_vault.db');
    _db = await openDatabase(
      dbPath,
      version: schemaVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableVaultItems (
            id TEXT PRIMARY KEY NOT NULL,
            type TEXT NOT NULL,
            title TEXT NOT NULL,
            url TEXT,
            domain TEXT,
            description TEXT,
            local_image_id TEXT,
            thumbnail_id TEXT,
            tags_json TEXT NOT NULL DEFAULT '[]',
            is_favorite INTEGER NOT NULL DEFAULT 0,
            collection TEXT NOT NULL DEFAULT 'General',
            file_size_bytes INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_vault_items_created ON $tableVaultItems(created_at DESC)',
        );
        await db.execute(
          'CREATE INDEX idx_vault_items_type ON $tableVaultItems(type)',
        );
        await db.execute(
          'CREATE INDEX idx_vault_items_favorite ON $tableVaultItems(is_favorite)',
        );
        await db.execute(
          'CREATE INDEX idx_vault_items_collection ON $tableVaultItems(collection)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE $tableVaultItems ADD COLUMN description TEXT',
          );
          await db.execute(
            "ALTER TABLE $tableVaultItems ADD COLUMN collection TEXT NOT NULL DEFAULT 'General'",
          );
          await db.execute(
            'ALTER TABLE $tableVaultItems ADD COLUMN file_size_bytes INTEGER NOT NULL DEFAULT 0',
          );
          await db.execute(
            'CREATE INDEX idx_vault_items_collection ON $tableVaultItems(collection)',
          );
        }
      },
    );
    return _db!;
  }

  Future<List<VaultItem>> getAllItems() async {
    final db = await database;
    final rows = await db.query(
      tableVaultItems,
      orderBy: 'created_at DESC, id ASC',
    );
    return rows.map(VaultItem.fromDbMap).toList();
  }

  Future<void> upsertItem(VaultItem item) async {
    final db = await database;
    await db.insert(
      tableVaultItems,
      item.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertItemsAtomically(List<VaultItem> items) async {
    final db = await database;
    await db.transaction((txn) async {
      for (final item in items) {
        await txn.insert(
          tableVaultItems,
          item.toDbMap(),
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      }
    });
  }

  Future<void> updateCollection(String itemId, String collection) async {
    final db = await database;
    await db.update(
      tableVaultItems,
      {
        'collection': collection,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  Future<void> updateCollections(
    List<String> itemIds,
    String collection,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      for (final id in itemIds) {
        await txn.update(
          tableVaultItems,
          {
            'collection': collection,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    });
  }

  Future<void> deleteItemById(String id) async {
    final db = await database;
    await db.delete(tableVaultItems, where: 'id = ?', whereArgs: [id]);
  }

  Future<Set<String>> getActiveReferencedImageIds({
    String? excludeItemId,
  }) async {
    final db = await database;
    final rows = await db.query(
      tableVaultItems,
      columns: ['id', 'local_image_id', 'thumbnail_id'],
    );
    final refs = <String>{};
    for (final row in rows) {
      if (excludeItemId != null && row['id'] == excludeItemId) continue;
      final img = row['local_image_id'] as String?;
      final thumb = row['thumbnail_id'] as String?;
      if (img != null && img.isNotEmpty) refs.add(img);
      if (thumb != null && thumb.isNotEmpty) refs.add(thumb);
    }
    return refs;
  }

  Future<int> getDatabaseFileSizeBytes() async {
    final db = await database;
    final path = db.path;
    if (path == inMemoryDatabasePath) return 0;
    final f = File(path);
    if (await f.exists()) {
      return f.length();
    }
    return 0;
  }

  Future<void> vacuum() async {
    final db = await database;
    if (db.path != inMemoryDatabasePath) {
      await db.execute('VACUUM');
    }
  }

  Future<void> clearAllItems() async {
    final db = await database;
    await db.delete(tableVaultItems);
  }

  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }
}
