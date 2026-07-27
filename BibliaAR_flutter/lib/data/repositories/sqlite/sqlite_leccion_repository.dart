import 'package:biblia_ar_flutter/data/database/app_database.dart';
import 'package:biblia_ar_flutter/data/models/leccion.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/leccion_repository.dart';

class SqliteLeccionRepository implements LeccionRepository {
  SqliteLeccionRepository(this._database);

  final AppDatabase _database;

  @override
  Future<List<Leccion>> obtenerTodas() async {
    final db = await _database.database;
    final rows = await db.query('lecciones', orderBy: 'orden ASC');
    return rows.map(Leccion.fromMap).toList();
  }

  @override
  Future<List<Leccion>> obtenerPorCategoria(String categoria) async {
    final db = await _database.database;
    final rows = await db.query(
      'lecciones',
      where: 'categoria = ?',
      whereArgs: [categoria],
      orderBy: 'orden ASC',
    );
    return rows.map(Leccion.fromMap).toList();
  }

  @override
  Future<Leccion?> obtenerPorId(int id) async {
    final db = await _database.database;
    final rows = await db.query(
      'lecciones',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return Leccion.fromMap(rows.first);
  }

  @override
  Future<Leccion> crear(Leccion leccion) async {
    final db = await _database.database;
    final id = await db.insert('lecciones', leccion.toMap());
    final creada = await obtenerPorId(id);
    return creada!;
  }

  @override
  Future<int> obtenerMaxOrden() async {
    final db = await _database.database;
    final rows = await db.rawQuery('SELECT MAX(orden) as max_orden FROM lecciones');
    final valor = rows.first['max_orden'];
    if (valor == null) {
      return 0;
    }
    return valor as int;
  }
}
