import 'package:biblia_ar_flutter/data/models/resultado_actividad.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Estructura base de vista de actividades del estudiante BIAR-52/53, variables v_resultados, 2026-07-14
class StudentActivityView extends StatelessWidget {
  const StudentActivityView({super.key, required this.vResultados});

  final List<ResultadoActividad> vResultados;

  @override
  Widget build(BuildContext context) {
    return Text('${vResultados.length} actividades');
  }
}
