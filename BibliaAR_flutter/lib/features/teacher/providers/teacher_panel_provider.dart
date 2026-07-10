import 'package:biblia_ar_flutter/features/teacher/models/teacher_panel_schema.dart';
import 'package:biblia_ar_flutter/features/teacher/validators/teacher_panel_validator.dart';
import 'package:flutter/foundation.dart';

// kguanoluisa, Provider del panel docente con validaciones BIAR-51, variables v_validador y v_ultimoError, 2026-07-10
class TeacherPanelProvider extends ChangeNotifier {
  TeacherPanelSchema v_esquema = TeacherPanelSchema.vPorDefecto;
  int v_indiceTab = 0;
  final TeacherPanelValidator v_validador = TeacherPanelValidator();
  String? v_ultimoError;

  TeacherPanelTab get vTabActiva => v_esquema.vTabActiva;
  String get vTituloPanel => v_esquema.vTituloPanel;

  void cambiarTab(int v_indice) {
    if (v_indice < 0 || v_indice > 1) {
      v_ultimoError = 'Indice de tab invalido.';
      notifyListeners();
      return;
    }
    v_indiceTab = v_indice;
    final v_nuevo = TeacherPanelSchema(
      vTabActiva: v_indice == 0 ? TeacherPanelTab.lecciones : TeacherPanelTab.seguimiento,
      vTituloPanel: v_esquema.vTituloPanel,
    );
    if (!v_validador.validarEsquema(v_nuevo)) {
      v_ultimoError = v_validador.errores.join(' ');
      notifyListeners();
      return;
    }
    v_ultimoError = null;
    v_esquema = v_nuevo;
    notifyListeners();
  }
}
