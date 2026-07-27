import 'package:biblia_ar_flutter/data/database/app_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:biblia_ar_flutter/data/models/actividad.dart';
import 'package:biblia_ar_flutter/data/models/resultado_actividad.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/actividad_repository.dart';

class SqliteActividadRepository implements ActividadRepository {
  SqliteActividadRepository(this._database);

  final AppDatabase _database;

  @override
  Future<List<Actividad>> obtenerPorLeccion(int leccionId) async {
    final db = await _database.database;
    final rows = await db.query(
      'actividades',
      where: 'leccion_id = ?',
      whereArgs: [leccionId],
      orderBy: 'id ASC',
    );
    return rows.map(Actividad.fromMap).toList();
  }

  @override
  Future<Actividad?> obtenerPorId(int id) async {
    final db = await _database.database;
    final rows = await db.query(
      'actividades',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return Actividad.fromMap(rows.first);
  }

  @override
  Future<void> guardarResultado(ResultadoActividad resultado) async {
    final db = await _database.database;
    await db.insert('resultados_actividad', resultado.toMap());
  }

  @override
  Future<int> contarIntentos(int perfilId, int actividadId) async {
    final db = await _database.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as total FROM resultados_actividad WHERE perfil_id = ? AND actividad_id = ?',
      [perfilId, actividadId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
