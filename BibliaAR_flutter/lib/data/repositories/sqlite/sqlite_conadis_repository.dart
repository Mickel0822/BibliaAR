import 'package:biblia_ar_flutter/data/database/database_access.dart';
import 'package:biblia_ar_flutter/data/models/certificado_conadis.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/conadis_repository.dart';

// Cristian Bayas, SQLite CONADIS consulta, cbayas0410@gmail.com, BIAR-65
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
    throw UnimplementedError('guardarConsulta pendiente de integración');
  }
}
