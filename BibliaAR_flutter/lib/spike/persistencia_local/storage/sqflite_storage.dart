import 'package:biblia_ar_flutter/spike/persistencia_local/storage/local_storage_adapter.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Implementación del spike usando SQLite vía sqflite.
///
/// Crea una tabla temporal `benchmark_registros` para medir
/// operaciones CRUD sin afectar la base de datos principal de la app.
class SqfliteStorageAdapter implements LocalStorageAdapter {
  SqfliteStorageAdapter({this.databaseName = 'spike_sqflite.db'});

  final String databaseName;
  Database? _database;

  static const String _table = 'benchmark_registros';

  @override
  String get name => 'sqflite';

  @override
  Future<void> initialize() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, databaseName);
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            perfil_id INTEGER NOT NULL,
            actividad_id INTEGER NOT NULL,
            resultado TEXT NOT NULL,
            fecha TEXT NOT NULL
          )
        ''');
      },
    );
  }

  @override
  Future<void> writeBatch(int count) async {
    final db = _database!;
    final batch = db.batch();
    final now = DateTime.now().toIso8601String();
    for (var i = 0; i < count; i++) {
      batch.insert(_table, {
        'perfil_id': 1,
        'actividad_id': i + 1,
        'resultado': 'correcto',
        'fecha': now,
      });
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<List<Map<String, dynamic>>> readAll() async {
    return _database!.query(_table, orderBy: 'id ASC');
  }

  @override
  Future<void> clear() async {
    await _database!.delete(_table);
  }

  @override
  Future<void> dispose() async {
    await _database?.close();
    _database = null;
  }
}
