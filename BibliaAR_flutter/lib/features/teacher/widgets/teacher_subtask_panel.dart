import 'package:flutter/material.dart';

// kguanoluisa, Estructura base de panel de subtareas docente BIAR-54/55, variable v_subtareas, 2026-07-17
class TeacherSubtaskPanel extends StatelessWidget {
  const TeacherSubtaskPanel({super.key, required this.v_subtareas});

  final List<String> v_subtareas;

  @override
  Widget build(BuildContext context) {
    return Column(children: v_subtareas.map(Text.new).toList());
  }
}
