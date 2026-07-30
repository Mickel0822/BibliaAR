import 'package:biblia_ar_flutter/data/database/database_access.dart';
import 'package:biblia_ar_flutter/data/database/migrations/migration_v1.dart';
import 'package:biblia_ar_flutter/data/database/migrations/migration_v4.dart';
import 'package:biblia_ar_flutter/data/repositories/sqlite/sqlite_conadis_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<Database> _crearDbConSeed() async {
  final db = await openDatabase(
    inMemoryDatabasePath,
    version: MigrationV4.version,
    onCreate: (db, version) async {
      for (final statement in MigrationV1.statements) {
        await db.execute(statement);
      }
      for (final statement in MigrationV4.statements) {
        await db.execute(statement);
      }
      await db.insert('certificados_conadis', {
        'numero_certificado': 'CON-2024-000001',
        'tipo_discapacidad': 'auditiva',
        'porcentaje': 85,
        'nombre_titular': 'María López',
      });
      await db.insert('certificados_conadis', {
        'numero_certificado': 'CON-2024-000002',
        'tipo_discapacidad': 'auditiva',
        'porcentaje': 45,
        'nombre_titular': 'Carlos Mendoza',
      });
      await db.insert('perfiles', {
        'nombre': 'Test',
        'tipo_usuario': 'nino',
        'creado_en': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    },
  );
  return db;
}

class _TestDatabase implements DatabaseAccess {
  _TestDatabase(this._db);
  final Database _db;
  @override
  Future<Database> get database async => _db;
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database db;
  late SqliteConadisRepository repository;

  setUp(() async {
    db = await _crearDbConSeed();
    repository = SqliteConadisRepository(_TestDatabase(db));
  });

  tearDown(() async {
    await db.close();
  });

  test('consultarPorNumero devuelve certificado existente', () async {
    final resultado = await repository.consultarPorNumero('CON-2024-000001');
    expect(resultado, isNotNull);
    expect(resultado!.tipoDiscapacidad, 'auditiva');
    expect(resultado.porcentaje, 85);
    expect(resultado.esDiscapacidadAuditiva, isTrue);
  });

  test('consultarPorNumero devuelve null si no existe', () async {
    final resultado = await repository.consultarPorNumero('CON-2099-999999');
    expect(resultado, isNull);
  });

  test('guardarConsulta persiste solo cuando el usuario lo elige', () async {
    final certificado = await repository.consultarPorNumero('CON-2024-000002');
    expect(certificado, isNotNull);

    await repository.guardarConsulta(perfilId: 1, certificado: certificado!);

    final rows = await db.query('consultas_conadis_guardadas');
    expect(rows, hasLength(1));
    expect(rows.first['numero_certificado'], 'CON-2024-000002');
  });
}
