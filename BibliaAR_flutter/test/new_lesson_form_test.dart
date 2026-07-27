import 'package:biblia_ar_flutter/features/lesson/leccion_provider.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/leccion_repository.dart';
import 'package:biblia_ar_flutter/data/models/leccion.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeLeccionRepositoryForForm implements LeccionRepository {
  @override
  Future<Leccion> crear(Leccion leccion) async => leccion;

  @override
  Future<int> obtenerMaxOrden() async => 0;

  @override
  Future<Leccion?> obtenerPorId(int id) async => null;

  @override
  Future<List<Leccion>> obtenerPorCategoria(String categoria) async => [];

  @override
  Future<List<Leccion>> obtenerTodas() async => [];
}

void main() {
  test('LeccionProvider rechaza historia vacia', () {
    final provider = LeccionProvider(leccionRepository: FakeLeccionRepositoryForForm());
    final error = provider.validarCampos(
      titulo: 'Titulo valido',
      historiaTexto: '',
      versiculoReferencia: 'Juan 3:16',
      versiculoTexto: 'Texto del versiculo',
    );
    expect(error, contains('historia'));
  });

  test('LeccionProvider rechaza titulo demasiado largo', () {
    final provider = LeccionProvider(leccionRepository: FakeLeccionRepositoryForForm());
    final error = provider.validarCampos(
      titulo: 'A' * 100,
      historiaTexto: 'Historia valida',
      versiculoReferencia: 'Juan 3:16',
      versiculoTexto: 'Texto del versiculo',
    );
    expect(error, isNotNull);
  });
}
