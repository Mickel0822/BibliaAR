import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Logica principal del panel de subtareas docente BIAR-54/55, variables v_subtareas y v_completadas, 2026-07-17
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
    return Card(
      margin: const EdgeInsets.all(BiarSpacing.md),
      child: ListView.separated(
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
    );
  }
}
