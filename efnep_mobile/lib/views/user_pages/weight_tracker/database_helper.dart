// ignore_for_file: depend_on_referenced_packages
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'weight_database.db');
    return openDatabase(path, version: 1, onCreate: _createTable);
  }

  Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE weight_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        weight REAL,
        date TEXT
      )
    ''');
  }

  Future<void> insertWeight(double weight, String date) async {
    final Database db = await database;
    await db.insert(
      'weight_entries',
      {'weight': weight, 'date': date},
    );
  }

  Future<List<Map<String, dynamic>>> getWeightEntries() async {
    final Database db = await database;
    return await db.query('weight_entries', orderBy: 'date DESC');
  }
}
