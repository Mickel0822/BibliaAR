import 'package:biblia_ar_flutter/data/models/leccion.dart';

abstract class LeccionRepository {
  Future<List<Leccion>> obtenerTodas();
  Future<List<Leccion>> obtenerPorCategoria(String categoria);
  Future<Leccion?> obtenerPorId(int id);
  Future<Leccion> crear(Leccion leccion);
  Future<int> obtenerMaxOrden();
}
