import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import './model.dart';

class DatabaseHelper {
  static Database _database;

  Future<Database> get database async {
    if (_database == null) {
      _database = await initialDB();
    }
    return _database;
  }

  initialDB() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, 'notes.db');
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database database, int ver) async {
    await database.execute(
        'CREATE TABLE "notes" (	"id"	INTEGER NOT NULL UNIQUE,	"title"	TEXT,	"content"	TEXT,	PRIMARY KEY("id" AUTOINCREMENT));');
  }

  Future<int> insertNote(Notes note) async {
    var db = await database;
    return await db.insert('notes', note.toDataBase());
  }

  Future<List> getNote([int id]) async {
    var db = await database;
    if (id == null)
      return await db.query('notes', orderBy: 'id DESC');
    else
      return await db.query('notes', where: 'id = $id');
  }

  Future<int> updateNote(Notes note) async {
    var db = await database;
    return await db.update('notes', note.toDataBase(),
        where: 'id = ${note.id}');
  }

  Future<int> deleteNote(int id) async {
    var db = await database;
    return await db.delete('notes', where: 'id = $id');
  }
}
