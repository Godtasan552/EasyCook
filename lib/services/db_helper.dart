import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  Database? _db;
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'easycook.db');

    return await openDatabase(path, version:1, onCreate: (db, version) async{

      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT UNIQUE,
          password TEXT
        )

      ''');
      await db.execute('''
        CREATE TABLE favorites (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER,
          idMeal TEXT,
          data TEXT,
          UNIQUE(userId, idMeal)
        )
      ''');
    });
  }

  //USER FUNCTIONS
  Future<int> createUser(String username, String passwordHash) async {
    final database = awit db;
    return await database.insert
  }
}