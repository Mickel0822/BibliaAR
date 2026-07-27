import 'package:biblia_ar_flutter/data/models/leccion.dart';
import 'package:biblia_ar_flutter/data/models/progreso.dart';
import 'package:biblia_ar_flutter/data/models/resultado_actividad.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/leccion_repository.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/progreso_repository.dart';
import 'package:biblia_ar_flutter/features/lesson/lesson_player_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeLeccionRepo implements LeccionRepository {
  FakeLeccionRepo(this.leccion);

  final Leccion? leccion;

  @override
  Future<Leccion> crear(Leccion leccion) async => leccion;

  @override
  Future<int> obtenerMaxOrden() async => 0;

  @override
  Future<Leccion?> obtenerPorId(int id) async => leccion;

  @override
  Future<List<Leccion>> obtenerPorCategoria(String categoria) async => [];

  @override
  Future<List<Leccion>> obtenerTodas() async => [];
}

class FakeProgresoRepo implements ProgresoRepository {
  @override
  Future<void> guardar(Progreso progreso) async {}

  @override
  Future<List<Progreso>> obtenerPorPerfil(int perfilId) async => [];

  @override
  Future<Progreso?> obtenerPorPerfilYLeccion(int perfilId, int leccionId) async => null;

  @override
  Future<List<ResultadoActividad>> obtenerResultadosPorPerfil(int perfilId) async => [];
}

void main() {
  test('LessonPlayerProvider construye fragmento desde leccion docente', () async {
    const leccion = Leccion(
      id: 2,
      titulo: 'Historia docente',
      referenciaBiblica: 'Juan 3:16',
      contenidoMultimediaPath: '',
      historiaTexto: 'Una historia creada por el docente.',
      versiculoReferencia: 'Juan 3:16',
      versiculoTexto: 'Porque de tal manera amó Dios al mundo.',
      pictograma: 'historias',
    );

    final provider = LessonPlayerProvider(
      leccionRepository: FakeLeccionRepo(leccion),
      progresoRepository: FakeProgresoRepo(),
    );

    await provider.cargarLeccion(leccionId: 2);

    expect(provider.vFragmentos.length, 1);
    expect(provider.fragmentoActual?.descripcion, leccion.historiaTexto);
    expect(provider.fragmentoActual?.pictogramas, ['historias']);
  });
}
