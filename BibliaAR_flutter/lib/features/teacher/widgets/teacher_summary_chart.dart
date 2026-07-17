import 'package:biblia_ar_flutter/features/teacher/models/teacher_summary_data.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Estructura base de grafico de resumen docente BIAR-54/55, variable v_datos, 2026-07-17
class TeacherSummaryChart extends StatelessWidget {
  const TeacherSummaryChart({super.key, required this.v_datos});

  final TeacherSummaryData v_datos;

  @override
  Widget build(BuildContext context) {
    return Text('Exito: ${v_datos.v_porcentajeExito.toStringAsFixed(1)}%');
  }
}
