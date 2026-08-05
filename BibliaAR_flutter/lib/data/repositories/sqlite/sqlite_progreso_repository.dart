import 'package:biblia_ar_flutter/data/database/app_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:biblia_ar_flutter/data/models/progreso.dart';
import 'package:biblia_ar_flutter/data/models/resultado_actividad.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/progreso_repository.dart';

class SqliteProgresoRepository implements ProgresoRepository {
  SqliteProgresoRepository(this._database);

  final AppDatabase _database;

  @override
  Future<List<Progreso>> obtenerPorPerfil(int perfilId) async {
    final db = await _database.database;
    final rows = await db.query(
      'progreso',
      where: 'perfil_id = ?',
      whereArgs: [perfilId],
      orderBy: 'fecha DESC',
    );
    return rows.map(Progreso.fromMap).toList();
  }

  @override
  Future<Progreso?> obtenerPorPerfilYLeccion(int perfilId, int leccionId) async {
    final db = await _database.database;
    final rows = await db.query(
      'progreso',
      where: 'perfil_id = ? AND leccion_id = ?',
      whereArgs: [perfilId, leccionId],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return Progreso.fromMap(rows.first);
  }

  @override
  Future<void> guardar(Progreso progreso) async {
    final db = await _database.database;
    await db.insert(
      'progreso',
      progreso.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<ResultadoActividad>> obtenerResultadosPorPerfil(int perfilId) async {
    final db = await _database.database;
    final rows = await db.query(
      'resultados_actividad',
      where: 'perfil_id = ?',
      whereArgs: [perfilId],
      orderBy: 'fecha DESC',
    );
    return rows.map(ResultadoActividad.fromMap).toList();
  }
}
