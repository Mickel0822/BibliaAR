import 'package:biblia_ar_flutter/data/models/actividad.dart';
import 'package:biblia_ar_flutter/data/models/resultado_actividad.dart';

abstract class ActividadRepository {
  Future<List<Actividad>> obtenerPorLeccion(int leccionId);
  Future<Actividad?> obtenerPorId(int id);
  Future<void> guardarResultado(ResultadoActividad resultado);
  Future<int> contarIntentos(int perfilId, int actividadId);
}
