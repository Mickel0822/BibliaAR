// kguanoluisa, Esquema del panel docente con tab de resumen BIAR-54/55, enum TeacherPanelTab resumen, 2026-07-17
enum TeacherPanelTab {
  lecciones,
  seguimiento,
  resumen,
}

class TeacherPanelSchema {
  const TeacherPanelSchema({
    required this.vTabActiva,
    required this.vTituloPanel,
  });

  final TeacherPanelTab vTabActiva;
  final String vTituloPanel;

  static const TeacherPanelSchema vPorDefecto = TeacherPanelSchema(
    vTabActiva: TeacherPanelTab.lecciones,
    vTituloPanel: 'Panel docente',
  );
}
