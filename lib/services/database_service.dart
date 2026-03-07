import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/media_item.dart';
import '../models/collection_type.dart';

class DatabaseService {
  // Singleton
  static final DatabaseService instance = DatabaseService._internal();
  factory DatabaseService() => instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'media_shelf.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE collection_types (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon_name TEXT NOT NULL,
        is_custom INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE media_items (
        id TEXT PRIMARY KEY,
        collection_type_id TEXT NOT NULL,
        title TEXT NOT NULL,
        creator TEXT NOT NULL,
        year INTEGER NOT NULL,
        genre TEXT,
        image_path TEXT,
        barcode TEXT,
        added_at TEXT NOT NULL,
        FOREIGN KEY (collection_type_id) REFERENCES collection_types (id)
      )
    ''');

    // Insert default collection types on first launch
    await _insertDefaults(db);
  }

  Future<void> _insertDefaults(Database db) async {
    for (final type in CollectionType.defaults) {
      await db.insert('collection_types', {
        'id': type.id,
        'name': type.name,
        'icon_name': type.iconName,
        'is_custom': 0,
      });
    }
  }

  // Collection Types
  Future<List<CollectionType>> getCollectionTypes() async {
    final db = await database;
    final rows = await db.query('collection_types');
    return rows.map((row) => CollectionType(
      id: row['id'] as String,
      name: row['name'] as String,
      iconName: row['icon_name'] as String,
      isCustom: row['is_custom'] == 1,
    )).toList();
  }

  Future<void> insertCollectionType(CollectionType type) async {
    final db = await database;
    await db.insert(
      'collection_types',
      {
        'id': type.id,
        'name': type.name,
        'icon_name': type.iconName,
        'is_custom': type.isCustom ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteCollectionType(String id) async {
    final db = await database;
    await db.delete('collection_types', where: 'id = ?', whereArgs: [id]);
    await db.delete('media_items', where: 'collection_type_id = ?', whereArgs: [id]);
  }


  // Media Items
  Future<List<MediaItem>> getItems() async {
    final db = await database;
    final rows = await db.query('media_items');
    return rows.map((row) => MediaItem(
        id: row['id'] as String,
        collectionTypeId: row['collection_type_id'] as String,
        title: row['title'] as String,
        creator: row['creator'] as String,
        year: row['year'] as int,
        genre: row['genre'] as String?,
        imagePath: row['image_path'] as String?,
      barcode: row['barcode'] as String?,
      addedAt: DateTime.parse(row['added_at'] as String),
    )).toList();
  }

  Future<void> insertItem(MediaItem item) async {
    final db = await database;
    await db.insert(
      'media_items',
      {
        'id': item.id,
        'collection_type_id': item.collectionTypeId,
        'title': item.title,
        'creator': item.creator,
        'year': item.year,
        'genre': item.genre,
        'image_path': item.imagePath,
        'barcode': item.barcode,
        'added_at': item.addedAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateItem(MediaItem item) async {
    final db = await database;
    await db.update(
      'media_items',
      {
        'title': item.title,
        'creator': item.creator,
        'year': item.year,
        'genre': item.genre,
        'image_path': item.imagePath,
        'barcode': item.barcode,
      },
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteItem(String id) async {
    final db = await database;
    await db.delete('media_items', where: 'id = ?', whereArgs: [id]);
  }
}