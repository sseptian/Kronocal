import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'kronocalc.db');

    return openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        await _createTables(db);
        await _seedDefaultUser(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createUsersTable(db);
          await _createGroupMembersTable(db);
          await _seedDefaultUser(db);
        }
        if (oldVersion < 3) {
          await db.execute("ALTER TABLE group_members ADD COLUMN nim TEXT NOT NULL DEFAULT ''");
        }
        if (oldVersion < 4) {
          await _rebuildGroupMembersTable(db);
        }
      },
    );
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE agendas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        color INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        birth_date TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE activities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        date_time TEXT NOT NULL,
        member_names TEXT
      )
    ''');
    await _createUsersTable(db);
    await _createGroupMembersTable(db);
  }

  static Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createGroupMembersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS group_members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        nim TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _rebuildGroupMembersTable(Database db) async {
    await db.execute('ALTER TABLE group_members RENAME TO group_members_old');
    await db.execute('''
      CREATE TABLE group_members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        nim TEXT NOT NULL
      )
    ''');
    await db.execute('''
      INSERT INTO group_members (id, name, nim)
      SELECT id, name, COALESCE(nim, '')
      FROM group_members_old
    ''');
    await db.execute('DROP TABLE group_members_old');
  }

  static Future<void> _seedDefaultUser(Database db) async {
    await db.insert('users', {'username': 'admin', 'password': '12345'},
      conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<bool> checkLogin(String username, String password) async {
    final database = await db;
    final rows = await database.query('users',
      where: 'username = ? AND password = ?', whereArgs: [username.trim(), password], limit: 1);
    return rows.isNotEmpty;
  }
}
