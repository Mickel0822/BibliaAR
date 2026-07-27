import 'package:biblia_ar_flutter/data/database/migrations/migration_v3.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('Migration v3 agrega columnas de leccion docente', () async {
    final db = await openDatabase(
      inMemoryDatabasePath,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE lecciones (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo TEXT NOT NULL,
            referencia_biblica TEXT NOT NULL,
            contenido_multimedia_path TEXT NOT NULL,
            categoria TEXT NOT NULL DEFAULT 'biblico',
            orden INTEGER NOT NULL DEFAULT 0,
            updated_at TEXT NOT NULL,
            sync_status TEXT NOT NULL DEFAULT 'local'
          )
        ''');
      },
    );

    for (final statement in MigrationV3.statements) {
      await db.execute(statement);
    }

    final rows = await db.query('lecciones');
    expect(rows, isEmpty);

    await db.insert('lecciones', {
      'titulo': 'Prueba',
      'referencia_biblica': 'Juan 3:16',
      'contenido_multimedia_path': '',
      'historia_texto': 'Historia demo',
      'versiculo_referencia': 'Juan 3:16',
      'versiculo_texto': 'Porque de tal manera...',
      'pictograma': 'historias',
      'updated_at': DateTime.now().toIso8601String(),
      'sync_status': 'local',
    });

    final insertadas = await db.query('lecciones');
    expect(insertadas.first['historia_texto'], 'Historia demo');
    expect(insertadas.first['pictograma'], 'historias');

    await db.close();
  });
}
