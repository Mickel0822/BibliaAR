import 'package:biblia_ar_flutter/features/teacher/models/teacher_panel_schema.dart';
import 'package:flutter/foundation.dart';

// kguanoluisa, Logica principal del esquema del panel docente BIAR-51, variables v_esquema y v_indiceTab, 2026-07-09
class TeacherPanelProvider extends ChangeNotifier {
  TeacherPanelSchema v_esquema = TeacherPanelSchema.vPorDefecto;
  int v_indiceTab = 0;

  TeacherPanelTab get vTabActiva => v_esquema.vTabActiva;
  String get vTituloPanel => v_esquema.vTituloPanel;

  void cambiarTab(int v_indice) {
    if (v_indice < 0 || v_indice > 1) return;
    v_indiceTab = v_indice;
    v_esquema = TeacherPanelSchema(
      vTabActiva: v_indice == 0 ? TeacherPanelTab.lecciones : TeacherPanelTab.seguimiento,
      vTituloPanel: v_esquema.vTituloPanel,
    );
    notifyListeners();
  }
}
