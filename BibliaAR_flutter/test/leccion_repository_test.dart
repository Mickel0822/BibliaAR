import 'package:biblia_ar_flutter/data/database/app_database.dart';
import 'package:biblia_ar_flutter/data/models/leccion.dart';
import 'package:biblia_ar_flutter/data/models/leccion_categoria.dart';
import 'package:biblia_ar_flutter/data/repositories/sqlite/sqlite_leccion_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('LeccionRepository.crear persiste leccion biblica docente', () async {
    final database = AppDatabase.instance;
    await database.close();

    final repo = SqliteLeccionRepository(database);
    final maxOrden = await repo.obtenerMaxOrden();

    final creada = await repo.crear(
      Leccion(
        titulo: 'La oveja perdida',
        referenciaBiblica: 'Lucas 15:4-7',
        contenidoMultimediaPath: '',
        categoria: LeccionCategoria.biblico,
        orden: maxOrden + 1,
        historiaTexto: 'Jesús contó una parábola sobre una oveja.',
        versiculoReferencia: 'Lucas 15:4-7',
        versiculoTexto: '¿Qué hombre de vosotros...?',
        pictograma: 'historias',
      ),
    );

    expect(creada.id, isNotNull);
    expect(creada.esLeccionDocente, isTrue);

    final porId = await repo.obtenerPorId(creada.id!);
    expect(porId?.titulo, 'La oveja perdida');

    await database.close();
  });
}
