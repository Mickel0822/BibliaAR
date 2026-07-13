import 'package:biblia_ar_flutter/features/teacher/models/teacher_panel_schema.dart';

// kguanoluisa, Validaciones del esquema del panel docente BIAR-51, variables v_errores, 2026-07-10
class TeacherPanelValidator {
  final List<String> v_errores = [];

  List<String> get errores => List.unmodifiable(v_errores);

  bool validarEsquema(TeacherPanelSchema v_esquema) {
    v_errores.clear();
    if (v_esquema.vTituloPanel.trim().isEmpty) {
      v_errores.add('El titulo del panel docente es obligatorio.');
    }
    if (v_esquema.vTituloPanel.length > 60) {
      v_errores.add('El titulo del panel no puede superar 60 caracteres.');
    }
    return v_errores.isEmpty;
  }
}
