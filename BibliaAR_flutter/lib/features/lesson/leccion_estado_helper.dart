import 'package:biblia_ar_flutter/data/models/estado_progreso.dart';
import 'package:biblia_ar_flutter/data/models/progreso.dart';

// kguanoluisa, Helper para resolver etiqueta de estado de leccion segun progreso del nino, sin nuevas variables, 2026-07-23
class LeccionEstadoHelper {
  static String resolverEstadoLeccion({
    required int leccionId,
    required List<Progreso> progresos,
  }) {
    final progreso = progresos.where((p) => p.leccionId == leccionId).toList();
    if (progreso.isEmpty) {
      return 'Nueva';
    }
    switch (progreso.first.estado) {
      case EstadoProgreso.completada:
        return 'Completada';
      case EstadoProgreso.enCurso:
        return 'En progreso';
      case EstadoProgreso.noIniciada:
        return 'Nueva';
    }
  }
}
