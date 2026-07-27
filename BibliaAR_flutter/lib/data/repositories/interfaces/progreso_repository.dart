import 'package:biblia_ar_flutter/data/models/progreso.dart';
import 'package:biblia_ar_flutter/data/models/resultado_actividad.dart';

abstract class ProgresoRepository {
  Future<List<Progreso>> obtenerPorPerfil(int perfilId);
  Future<Progreso?> obtenerPorPerfilYLeccion(int perfilId, int leccionId);
  Future<void> guardar(Progreso progreso);
  Future<List<ResultadoActividad>> obtenerResultadosPorPerfil(int perfilId);
}
