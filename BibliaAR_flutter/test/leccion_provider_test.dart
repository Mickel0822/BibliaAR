import 'package:biblia_ar_flutter/data/models/leccion.dart';
import 'package:biblia_ar_flutter/data/models/leccion_categoria.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/leccion_repository.dart';
import 'package:biblia_ar_flutter/features/lesson/leccion_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeLeccionRepository implements LeccionRepository {
  final List<Leccion> lecciones = [];
  int _id = 1;

  @override
  Future<Leccion> crear(Leccion leccion) async {
    final creada = Leccion(
      id: _id++,
      titulo: leccion.titulo,
      referenciaBiblica: leccion.referenciaBiblica,
      contenidoMultimediaPath: leccion.contenidoMultimediaPath,
      categoria: leccion.categoria,
      orden: leccion.orden,
      historiaTexto: leccion.historiaTexto,
      versiculoReferencia: leccion.versiculoReferencia,
      versiculoTexto: leccion.versiculoTexto,
      pictograma: leccion.pictograma,
    );
    lecciones.add(creada);
    return creada;
  }

  @override
  Future<int> obtenerMaxOrden() async {
    if (lecciones.isEmpty) return 0;
    return lecciones.map((l) => l.orden).reduce((a, b) => a > b ? a : b);
  }

  @override
  Future<List<Leccion>> obtenerPorCategoria(String categoria) async {
    return lecciones.where((l) => l.categoria == categoria).toList();
  }

  @override
  Future<List<Leccion>> obtenerTodas() async => lecciones;

  @override
  Future<Leccion?> obtenerPorId(int id) async {
    for (final leccion in lecciones) {
      if (leccion.id == id) return leccion;
    }
    return null;
  }
}

void main() {
  test('LeccionProvider recarga lista tras crear leccion docente', () async {
    final repo = FakeLeccionRepository();
    repo.lecciones.add(
      const Leccion(
        id: 1,
        titulo: 'Buen Samaritano',
        referenciaBiblica: 'Lucas 10:25-37',
        contenidoMultimediaPath: 'assets/demo.json',
        categoria: LeccionCategoria.biblico,
        orden: 1,
      ),
    );

    final provider = LeccionProvider(leccionRepository: repo);
    await provider.cargarLeccionesBiblicas();
    expect(provider.vLeccionesBiblicas.length, 1);

    final creada = await provider.crearLeccionDocente(
      titulo: 'Nueva historia',
      historiaTexto: 'Texto de prueba suficientemente largo.',
      versiculoReferencia: 'Juan 3:16',
      versiculoTexto: 'Porque de tal manera amó Dios al mundo.',
    );

    expect(creada, isNotNull);
    expect(provider.vLeccionesBiblicas.length, 2);
  });

  test('LeccionProvider valida campos obligatorios', () {
    final provider = LeccionProvider(leccionRepository: FakeLeccionRepository());
    final error = provider.validarCampos(
      titulo: '',
      historiaTexto: 'Historia',
      versiculoReferencia: 'Juan 3:16',
      versiculoTexto: 'Texto',
    );
    expect(error, isNotNull);
  });
}
