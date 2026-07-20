import 'package:biblia_ar_flutter/features/teacher/models/teacher_summary_data.dart';

// kguanoluisa, Validaciones de graficos y subtareas docentes BIAR-54/55, variables v_errores, 2026-07-20
class TeacherChartValidator {
  final List<String> v_errores = [];

  List<String> get errores => List.unmodifiable(v_errores);

  bool validarResumen(TeacherSummaryData v_datos) {
    v_errores.clear();
    if (v_datos.v_totalIntentos < 0 || v_datos.v_totalCorrectos < 0) {
      v_errores.add('Los totales del resumen no pueden ser negativos.');
    }
    if (v_datos.v_totalCorrectos > v_datos.v_totalIntentos) {
      v_errores.add('Los aciertos no pueden superar los intentos.');
    }
    return v_errores.isEmpty;
  }

  bool validarSubtareas(List<String> v_subtareas) {
    v_errores.clear();
    if (v_subtareas.isEmpty) {
      v_errores.add('Debe existir al menos una subtarea docente.');
    }
    return v_errores.isEmpty;
  }
}
