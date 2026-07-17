// kguanoluisa, Estructura base de datos de resumen docente BIAR-54/55, variables v_totalCorrectos v_totalIntentos, 2026-07-17
class TeacherSummaryData {
  const TeacherSummaryData({
    required this.v_totalCorrectos,
    required this.v_totalIntentos,
    required this.v_totalEstudiantes,
  });

  final int v_totalCorrectos;
  final int v_totalIntentos;
  final int v_totalEstudiantes;

  double get v_porcentajeExito =>
      v_totalIntentos == 0 ? 0 : (v_totalCorrectos / v_totalIntentos) * 100;
}
