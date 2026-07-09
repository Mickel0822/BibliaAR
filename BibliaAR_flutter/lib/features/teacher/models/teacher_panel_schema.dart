// kguanoluisa, Estructura base del esquema del panel docente BIAR-51, enum TeacherPanelTab, 2026-07-09
enum TeacherPanelTab {
  lecciones,
  seguimiento,
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
