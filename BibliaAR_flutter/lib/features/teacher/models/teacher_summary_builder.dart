import 'package:biblia_ar_flutter/data/models/resultado_actividad.dart';
import 'package:biblia_ar_flutter/features/teacher/models/teacher_summary_data.dart';

// kguanoluisa, Refactor de construccion de datos de resumen docente BIAR-54/55, clase TeacherSummaryBuilder, 2026-07-22
class TeacherSummaryBuilder {
  const TeacherSummaryBuilder();

  TeacherSummaryData fromResultados({
    required List<ResultadoActividad> v_resultados,
    required int v_totalEstudiantes,
  }) {
    final v_correctos = v_resultados.where((r) => r.resultado == 'correcto').length;
    return TeacherSummaryData(
      v_totalCorrectos: v_correctos,
      v_totalIntentos: v_resultados.length,
      v_totalEstudiantes: v_totalEstudiantes,
    );
  }
}
