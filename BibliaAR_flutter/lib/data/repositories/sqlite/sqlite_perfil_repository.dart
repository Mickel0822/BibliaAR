import 'package:biblia_ar_flutter/data/database/app_database.dart';
import 'package:biblia_ar_flutter/data/models/perfil.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/perfil_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

// kguanoluisa, Implementacion SQLite del repositorio de perfiles con perfil activo en SharedPreferences, variable v_prefPerfilActivoKey, 2026-07-23
class SqlitePerfilRepository implements PerfilRepository {
  SqlitePerfilRepository(this._database);

  final AppDatabase _database;
  static const String vPrefPerfilActivoKey = 'perfil_activo_id';

  @override
  Future<List<Perfil>> obtenerTodos() async {
    final db = await _database.database;
    final rows = await db.query('perfiles', orderBy: 'nombre ASC');
    return rows.map(Perfil.fromMap).toList();
  }

  @override
  Future<List<Perfil>> obtenerPorTipo(String tipoUsuario) async {
    final db = await _database.database;
    final rows = await db.query(
      'perfiles',
      where: 'tipo_usuario = ?',
      whereArgs: [tipoUsuario],
      orderBy: 'nombre ASC',
    );
    return rows.map(Perfil.fromMap).toList();
  }

  @override
  Future<Perfil?> obtenerPorId(int id) async {
    final db = await _database.database;
    final rows = await db.query(
      'perfiles',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return Perfil.fromMap(rows.first);
  }

  @override
  Future<Perfil> crear(Perfil perfil) async {
    final db = await _database.database;
    final id = await db.insert('perfiles', perfil.toMap());
    return perfil.copyWith(id: id);
  }

  @override
  Future<void> eliminar(int id) async {
    final db = await _database.database;
    await db.delete('perfiles', where: 'id = ?', whereArgs: [id]);
    await db.delete('configuracion', where: 'perfil_id = ?', whereArgs: [id]);
  }

  @override
  Future<int?> obtenerPerfilActivoId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(vPrefPerfilActivoKey);
    return id;
  }

  @override
  Future<void> guardarPerfilActivoId(int perfilId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(vPrefPerfilActivoKey, perfilId);
  }

  @override
  Future<void> limpiarPerfilActivo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(vPrefPerfilActivoKey);
  }
}
