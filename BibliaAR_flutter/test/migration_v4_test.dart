import 'package:biblia_ar_flutter/data/database/migrations/migration_v4.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('Migration v4 crea tablas certificados_conadis y consultas_conadis_guardadas', () async {
    final db = await openDatabase(
      inMemoryDatabasePath,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE perfiles (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            tipo_usuario TEXT NOT NULL,
            avatar_path TEXT,
            creado_en TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            sync_status TEXT NOT NULL DEFAULT 'local'
          )
        ''');
      },
    );

    for (final statement in MigrationV4.statements) {
      await db.execute(statement);
    }

    await db.insert('certificados_conadis', {
      'numero_certificado': 'CON-2024-000001',
      'tipo_discapacidad': 'auditiva',
      'porcentaje': 85,
      'nombre_titular': 'María López',
    });

    final certificados = await db.query('certificados_conadis');
    expect(certificados, hasLength(1));
    expect(certificados.first['tipo_discapacidad'], 'auditiva');

    await db.insert('perfiles', {
      'nombre': 'Test',
      'tipo_usuario': 'nino',
      'creado_en': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    await db.insert('consultas_conadis_guardadas', {
      'perfil_id': 1,
      'numero_certificado': 'CON-2024-000001',
      'tipo_discapacidad': 'auditiva',
      'porcentaje': 85,
      'consultado_en': DateTime.now().toIso8601String(),
    });

    final consultas = await db.query('consultas_conadis_guardadas');
    expect(consultas, hasLength(1));

    await db.close();
  });
}
