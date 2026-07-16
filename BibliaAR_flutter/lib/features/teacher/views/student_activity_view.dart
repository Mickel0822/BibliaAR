import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/data/models/resultado_actividad.dart';
import 'package:biblia_ar_flutter/features/teacher/validators/student_view_validator.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Optimizacion de listado de actividades con cache de agrupacion BIAR-52/53, variable v_cacheAgrupados, 2026-07-16
class StudentActivityView extends StatefulWidget {
  const StudentActivityView({super.key, required this.vResultados});

  final List<ResultadoActividad> vResultados;

  @override
  State<StudentActivityView> createState() => _StudentActivityViewState();
}

class _StudentActivityViewState extends State<StudentActivityView> {
  final StudentViewValidator v_validador = StudentViewValidator();
  Map<int, List<ResultadoActividad>>? v_cacheAgrupados;
  int? v_cacheLength;

  Color _colorEstado(String v_resultado) =>
      v_resultado == 'correcto' ? Colors.green.shade100 : Colors.orange.shade100;

  Map<int, List<ResultadoActividad>> _agrupar() {
    if (v_cacheAgrupados != null && v_cacheLength == widget.vResultados.length) {
      return v_cacheAgrupados!;
    }
    final v_agrupados = <int, List<ResultadoActividad>>{};
    for (final v_item in widget.vResultados) {
      v_agrupados.putIfAbsent(v_item.actividadId, () => []).add(v_item);
    }
    v_cacheAgrupados = v_agrupados;
    v_cacheLength = widget.vResultados.length;
    return v_agrupados;
  }

  @override
  Widget build(BuildContext context) {
    if (!v_validador.validarResultados(widget.vResultados)) {
      return Center(child: Text(v_validador.errores.join('\n')));
    }
    if (widget.vResultados.isEmpty) {
      return const Center(child: Text('Sin actividades registradas'));
    }

    final v_agrupados = _agrupar();

    return ListView.builder(
      padding: const EdgeInsets.all(BiarSpacing.md),
      itemCount: v_agrupados.length,
      itemBuilder: (context, index) {
        final v_actividadId = v_agrupados.keys.elementAt(index);
        final v_intentos = v_agrupados[v_actividadId]!;
        final v_ultimo = v_intentos.last;
        return Card(
          margin: const EdgeInsets.only(bottom: BiarSpacing.sm),
          child: ListTile(
            title: Text('Actividad #$v_actividadId'),
            subtitle: Text('${v_intentos.length} intento(s)'),
            trailing: Chip(
              label: Text(v_ultimo.resultado),
              backgroundColor: _colorEstado(v_ultimo.resultado),
            ),
          ),
        );
      },
    );
  }
}
