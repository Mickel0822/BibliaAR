import 'package:biblia_ar_flutter/data/database/app_database.dart';
import 'package:biblia_ar_flutter/data/models/historial_actividad_entry.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/historial_actividad_repository.dart';
import 'package:sqflite/sqflite.dart';

/// Implementación SQLite del historial de actividades por perfil (BIAR-44).
///
/// Consulta la tabla `resultados_actividad` unida con `actividades`
/// para mostrar títulos legibles en el panel de perfil.
class SqliteHistorialActividadRepository implements HistorialActividadRepository {
  SqliteHistorialActividadRepository(this._database);

  final AppDatabase _database;

  @override
  Future<List<HistorialActividadEntry>> obtenerPorPerfil(int perfilId) async {
    final db = await _database.database;
    final rows = await db.rawQuery('''
      SELECT
        r.id,
        r.perfil_id,
        r.actividad_id,
        r.resultado,
        r.intento_numero,
        r.fecha,
        COALESCE(json_extract(a.payload_json, '\$.titulo'), 'Actividad') AS titulo_actividad
      FROM resultados_actividad r
      LEFT JOIN actividades a ON a.id = r.actividad_id
      WHERE r.perfil_id = ?
      ORDER BY r.fecha DESC
    ''', [perfilId]);

    return rows.map(HistorialActividadEntry.fromMap).toList();
  }

  @override
  Future<void> registrarIntento(HistorialActividadEntry entry) async {
    final db = await _database.database;
    await db.insert('resultados_actividad', {
      'perfil_id': entry.perfilId,
      'actividad_id': entry.actividadId,
      'resultado': entry.resultado,
      'intento_numero': entry.intentoNumero,
      'fecha': entry.fecha.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'sync_status': 'local',
    });
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
