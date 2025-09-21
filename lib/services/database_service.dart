import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/declutter_item.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'kanso.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String _usersTable = 'users';
  static const String _itemsTable = 'declutter_items';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE $_usersTable (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        totalSessions INTEGER DEFAULT 0,
        totalItemsLetGo INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        isChinese INTEGER DEFAULT 0
      )
    ''');

    // Create declutter items table
    await db.execute('''
      CREATE TABLE $_itemsTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        photoPath TEXT,
        memo TEXT,
        createdAt TEXT NOT NULL,
        isKept INTEGER DEFAULT 0,
        isDiscarded INTEGER DEFAULT 0,
        userId TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES $_usersTable (id)
      )
    ''');
  }

  // User operations
  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert(
      _usersTable,
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUser(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _usersTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _usersTable,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      _usersTable,
      user.toJson(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Item operations
  Future<void> insertItem(DeclutterItem item, String userId) async {
    final db = await database;
    final itemJson = item.toJson();
    itemJson['userId'] = userId;
    await db.insert(
      _itemsTable,
      itemJson,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DeclutterItem>> getItemsByUser(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _itemsTable,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return DeclutterItem.fromJson(maps[i]);
    });
  }

  Future<List<DeclutterItem>> getDiscardedItemsByUser(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _itemsTable,
      where: 'userId = ? AND isDiscarded = 1',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return DeclutterItem.fromJson(maps[i]);
    });
  }

  Future<void> updateItem(DeclutterItem item) async {
    final db = await database;
    await db.update(
      _itemsTable,
      item.toJson(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteItem(String id) async {
    final db = await database;
    await db.delete(
      _itemsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearUserData(String userId) async {
    final db = await database;
    await db.delete(
      _itemsTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }
}
