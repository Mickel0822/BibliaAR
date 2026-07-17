import 'package:biblia_ar_flutter/features/teacher/models/teacher_panel_schema.dart';
import 'package:biblia_ar_flutter/features/teacher/validators/teacher_panel_validator.dart';
import 'package:flutter/foundation.dart';

// kguanoluisa, Optimizacion del panel docente evitando notifyListeners redundantes BIAR-51, variable v_ultimoIndice, 2026-07-13
class TeacherPanelProvider extends ChangeNotifier {
  TeacherPanelSchema v_esquema = TeacherPanelSchema.vPorDefecto;
  int v_indiceTab = 0;
  int? v_ultimoIndice;
  final TeacherPanelValidator v_validador = TeacherPanelValidator();
  String? v_ultimoError;
  bool v_sincronizandoTab = false;

  TeacherPanelTab get vTabActiva => v_esquema.vTabActiva;
  String get vTituloPanel => v_esquema.vTituloPanel;

  void cambiarTab(int v_indice, {bool v_desdeController = false}) {
    if (v_sincronizandoTab || v_ultimoIndice == v_indice) return;
    if (v_indice < 0 || v_indice > 2) {
      v_ultimoError = 'Indice de tab invalido.';
      notifyListeners();
      return;
    }
    v_sincronizandoTab = v_desdeController;
    v_indiceTab = v_indice;
    v_ultimoIndice = v_indice;
    final v_nuevo = TeacherPanelSchema(
      vTabActiva: v_indice == 0
        ? TeacherPanelTab.lecciones
        : v_indice == 1
            ? TeacherPanelTab.seguimiento
            : TeacherPanelTab.resumen,
      vTituloPanel: v_esquema.vTituloPanel,
    );
    if (!v_validador.validarEsquema(v_nuevo)) {
      v_ultimoError = v_validador.errores.join(' ');
      v_sincronizandoTab = false;
      notifyListeners();
      return;
    }
    v_ultimoError = null;
    v_esquema = v_nuevo;
    v_sincronizandoTab = false;
    notifyListeners();
  }
}
