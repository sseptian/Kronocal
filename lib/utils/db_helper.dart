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

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabel Agenda/Kalender
        await db.execute('''
          CREATE TABLE agendas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            date TEXT,
            time TEXT,
            color INTEGER
          )
        ''');

        // Tabel Anggota
        await db.execute('''
          CREATE TABLE members (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            birth_date TEXT
          )
        ''');

        // Tabel Kegiatan & Pendaftaran Anggota
        await db.execute('''
          CREATE TABLE activities (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            date_time TEXT,
            member_names TEXT
          )
        ''');
      },
    );
  }
}