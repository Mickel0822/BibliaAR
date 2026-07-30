import 'package:biblia_ar_flutter/data/database/database_access.dart';
import 'package:biblia_ar_flutter/data/models/certificado_conadis.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/conadis_repository.dart';

// kguanoluisa, Implementacion SQLite del repositorio CONADIS con consulta offline y guardado opt-in, sin nuevas variables, 2026-07-29
class SqliteConadisRepository implements ConadisRepository {
  SqliteConadisRepository(this._database);

  final DatabaseAccess _database;

  @override
  Future<CertificadoConadis?> consultarPorNumero(String numeroCertificado) async {
    final db = await _database.database;
    final rows = await db.query(
      'certificados_conadis',
      where: 'numero_certificado = ?',
      whereArgs: [numeroCertificado],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return CertificadoConadis.fromMap(rows.first);
  }

  @override
  Future<void> guardarConsulta({
    required int perfilId,
    required CertificadoConadis certificado,
  }) async {
    final db = await _database.database;
    await db.insert('consultas_conadis_guardadas', {
      'perfil_id': perfilId,
      'numero_certificado': certificado.numeroCertificado,
      'tipo_discapacidad': certificado.tipoDiscapacidad,
      'porcentaje': certificado.porcentaje,
      'consultado_en': DateTime.now().toIso8601String(),
    });
  }
}
