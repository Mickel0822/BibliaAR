import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/data/models/resultado_actividad.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Logica principal de vista de actividades del estudiante BIAR-52/53, variables v_resultados y v_colorEstado, 2026-07-14
class StudentActivityView extends StatelessWidget {
  const StudentActivityView({super.key, required this.vResultados});

  final List<ResultadoActividad> vResultados;

  Color _colorEstado(String v_resultado) =>
      v_resultado == 'correcto' ? Colors.green.shade100 : Colors.orange.shade100;

  @override
  Widget build(BuildContext context) {
    if (vResultados.isEmpty) {
      return const Center(child: Text('Sin actividades registradas'));
    }

    final v_agrupados = <int, List<ResultadoActividad>>{};
    for (final v_item in vResultados) {
      v_agrupados.putIfAbsent(v_item.actividadId, () => []).add(v_item);
    }

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
