import 'package:sqflite/sqflite.dart';

// kguanoluisa, Interfaz minima de acceso a SQLite para repositorios testeables, sin nuevas variables, 2026-07-29
abstract class DatabaseAccess {
  Future<Database> get database;
}
