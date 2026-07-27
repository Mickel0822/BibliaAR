import 'package:biblia_ar_flutter/data/database/app_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:biblia_ar_flutter/data/models/configuracion_sensorial.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/configuracion_repository.dart';

class SqliteConfiguracionRepository implements ConfiguracionRepository {
  SqliteConfiguracionRepository(this._database);

  final AppDatabase _database;

  @override
  Future<ConfiguracionSensorial?> obtenerPorPerfil(int perfilId) async {
    final db = await _database.database;
    final rows = await db.query(
      'configuracion',
      where: 'perfil_id = ?',
      whereArgs: [perfilId],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return ConfiguracionSensorial.fromMap(rows.first);
  }

  @override
  Future<void> guardar(ConfiguracionSensorial configuracion) async {
    final db = await _database.database;
    await db.insert(
      'configuracion',
      configuracion.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<ConfiguracionSensorial> crearPorDefecto(int perfilId) async {
    final configuracion = ConfiguracionSensorial(
      perfilId: perfilId,
      updatedAt: DateTime.now(),
    );
    await guardar(configuracion);
    return configuracion;
  }
}
