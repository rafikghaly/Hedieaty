import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseInitializer {
  static final DatabaseInitializer _instance = DatabaseInitializer._internal();
  factory DatabaseInitializer() => _instance;
  DatabaseInitializer._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE IF NOT EXISTS users(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, email TEXT, preferences TEXT, password TEXT)',
        );
        await db.execute(
          'CREATE TABLE IF NOT EXISTS friends(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, picture TEXT, upcomingEvents INTEGER)',
        );
        await db.execute(
          'CREATE TABLE IF NOT EXISTS events(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, category TEXT, status TEXT, date TEXT, location TEXT, description TEXT, userId INTEGER)',        );
        await db.execute(
          'CREATE TABLE IF NOT EXISTS gifts(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, description TEXT, category TEXT, price REAL, status TEXT, isPledged INTEGER, imageUrl TEXT, eventId INTEGER)',
        );
        // TODO add all Tables
      },
    );
  }
}
