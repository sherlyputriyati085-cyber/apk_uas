import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('freshtrack.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS foods');
          await _createDB(db, newVersion);
        } else if (oldVersion < 3) {
          await db.execute('''
          CREATE TABLE history (
            id TEXT PRIMARY KEY,
            title TEXT,
            foodName TEXT,
            timestamp TEXT,
            icon INTEGER,
            color INTEGER
          )
          ''');
        }
      },
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE foods (
      id INTEGER PRIMARY KEY,
      name TEXT,
      category TEXT,
      expiryDate TEXT,
      notes TEXT,
      imagePath TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE history (
      id TEXT PRIMARY KEY,
      title TEXT,
      foodName TEXT,
      timestamp TEXT,
      icon INTEGER,
      color INTEGER
    )
    ''');
  }

  Future<int> insertFood(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('foods', row);
  }

  Future<List<Map<String, dynamic>>> getFoods() async {
    final db = await instance.database;
    return await db.query('foods');
  }

  Future<int> deleteFood(int id) async {
    final db = await instance.database;
    return await db.delete('foods', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateFood(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.update(
      'foods',
      row,
      where: 'id = ?',
      whereArgs: [row['id']],
    );
  }

  // Helper methods for history
  Future<int> insertHistory(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert(
      'history',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await instance.database;
    return await db.query('history', orderBy: 'timestamp DESC');
  }

  Future<int> clearHistory() async {
    final db = await instance.database;
    return await db.delete('history');
  }
}
