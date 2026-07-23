/// Estado del ticket BIAR-50 en el flujo Jira.
enum Biar50JiraStatus {
  /// En desarrollo o revisión.
  enProgreso,

  /// Criterios cumplidos, listo para cerrar.
  listo,
}

/// Criterio de aceptación verificado para el cierre de BIAR-50.
class Biar50AcceptanceCriterion {
  const Biar50AcceptanceCriterion({
    required this.id,
    required this.descripcion,
    required this.cumplido,
    this.evidencia,
  });

  final String id;
  final String descripcion;
  final bool cumplido;
  final String? evidencia;
}

/// Informe de cierre del ticket BIAR-50 (paso a columna Listo).
class Biar50ClosureReport {
  const Biar50ClosureReport({
    required this.ticketId,
    required this.estado,
    required this.criterios,
    required this.fechaCierre,
    this.observaciones,
  });

  final String ticketId;
  final Biar50JiraStatus estado;
  final List<Biar50AcceptanceCriterion> criterios;
  final DateTime fechaCierre;
  final String? observaciones;

  int get totalCriterios => criterios.length;
  int get criteriosCumplidos => criterios.where((c) => c.cumplido).length;
  bool get puedePasarAListo =>
      criteriosCumplidos == totalCriterios && totalCriterios > 0;
}
