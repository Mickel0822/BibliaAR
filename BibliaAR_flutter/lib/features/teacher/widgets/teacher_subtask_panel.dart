import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Comentarios de revision cruzada en panel de subtareas BIAR-54/55, variable v_etiquetaProgreso, 2026-07-21
class TeacherSubtaskPanel extends StatelessWidget {
  const TeacherSubtaskPanel({
    super.key,
    required this.v_subtareas,
    required this.v_completadas,
  });

  final List<String> v_subtareas;
  final Set<int> v_completadas;

  @override
  Widget build(BuildContext context) {
    final v_etiquetaProgreso = '${v_completadas.length}/${v_subtareas.length} completadas';

    return Card(
      margin: const EdgeInsets.all(BiarSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(BiarSpacing.md, BiarSpacing.md, BiarSpacing.md, 0),
            child: Text('Subtareas docentes', style: Theme.of(context).textTheme.titleMedium),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: BiarSpacing.md),
            child: Text(v_etiquetaProgreso, style: Theme.of(context).textTheme.bodySmall),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(BiarSpacing.md),
            itemCount: v_subtareas.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final v_hecho = v_completadas.contains(index);
              return ListTile(
                leading: Icon(v_hecho ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: v_hecho ? Colors.green : null),
                title: Text(v_subtareas[index]),
              );
            },
          ),
        ],
      ),
    );
  }
}
