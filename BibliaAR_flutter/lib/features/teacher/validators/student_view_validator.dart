import 'package:biblia_ar_flutter/data/models/perfil.dart';
import 'package:biblia_ar_flutter/data/models/resultado_actividad.dart';

// kguanoluisa, Validaciones de vistas individuales de estudiantes BIAR-52/53, variables v_errores, 2026-07-15
class StudentViewValidator {
  final List<String> v_errores = [];

  List<String> get errores => List.unmodifiable(v_errores);

  bool validarPerfil(Perfil? v_perfil) {
    v_errores.clear();
    if (v_perfil == null) {
      v_errores.add('Debe seleccionar un estudiante.');
      return false;
    }
    if (v_perfil.nombre.trim().isEmpty) {
      v_errores.add('El nombre del estudiante es invalido.');
      return false;
    }
    return true;
  }

  bool validarResultados(List<ResultadoActividad> v_resultados) {
    v_errores.clear();
    if (v_resultados.any((r) => r.actividadId <= 0)) {
      v_errores.add('Hay resultados con actividad invalida.');
      return false;
    }
    return true;
  }
}
