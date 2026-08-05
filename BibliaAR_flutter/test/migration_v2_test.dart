import 'package:biblia_ar_flutter/data/database/migrations/migration_v2.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('Migration v2 agrega columna categoria con valor por defecto', () async {
    final db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE lecciones (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo TEXT NOT NULL,
            referencia_biblica TEXT NOT NULL,
            contenido_multimedia_path TEXT NOT NULL,
            orden INTEGER NOT NULL DEFAULT 0,
            updated_at TEXT NOT NULL,
            sync_status TEXT NOT NULL DEFAULT 'local'
          )
        ''');
        await db.insert('lecciones', {
          'titulo': 'Leccion previa',
          'referencia_biblica': 'Demo',
          'contenido_multimedia_path': 'assets/demo/fragments.json',
          'orden': 1,
          'updated_at': DateTime.now().toIso8601String(),
          'sync_status': 'local',
        });
      },
    );

    for (final statement in MigrationV2.statements) {
      await db.execute(statement);
    }

    final rows = await db.query('lecciones');
    expect(rows, isNotEmpty);
    expect(rows.first['categoria'], 'biblico');

    await db.close();
  });
}
