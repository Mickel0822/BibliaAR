import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/features/teacher/models/teacher_summary_data.dart';
import 'package:biblia_ar_flutter/features/teacher/validators/teacher_chart_validator.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_section_header.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Ajustes UI/UX del grafico de resumen docente BIAR-54/55, sin nuevas variables, 2026-07-20
class TeacherSummaryChart extends StatelessWidget {
  const TeacherSummaryChart({super.key, required this.v_datos});

  final TeacherSummaryData v_datos;
  static final TeacherChartValidator v_validador = TeacherChartValidator();

  @override
  Widget build(BuildContext context) {
    if (!v_validador.validarResumen(v_datos)) {
      return Card(
        margin: const EdgeInsets.all(BiarSpacing.md),
        child: Padding(
          padding: const EdgeInsets.all(BiarSpacing.md),
          child: Text(v_validador.errores.join('\n')),
        ),
      );
    }

    final v_color = Theme.of(context).colorScheme.primary;
    final v_ratio = (v_datos.v_porcentajeExito / 100).clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.all(BiarSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(BiarSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BiarSectionHeader(
              vTitulo: 'Grafico de resumen',
              vSubtitulo: 'Indicadores globales del grupo',
              vIcono: Icons.insights,
            ),
            const SizedBox(height: BiarSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(BiarRadius.sm),
              child: LinearProgressIndicator(value: v_ratio, color: v_color, minHeight: 14),
            ),
            const SizedBox(height: BiarSpacing.sm),
            Text('${v_datos.v_porcentajeExito.toStringAsFixed(1)}% de aciertos',
                style: Theme.of(context).textTheme.titleSmall),
            Text('${v_datos.v_totalEstudiantes} estudiantes · ${v_datos.v_totalIntentos} intentos'),
          ],
        ),
      ),
    );
  }
}
