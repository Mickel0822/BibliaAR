/// Resultado de una comprobación individual del checklist BIAR-50.
///
/// Cada ítem verifica un aspecto de la alerta de uso continuo de 20 minutos
/// (umbrales, pausa, reinicio, diálogo).
class UsageAlertCheckItem {
  const UsageAlertCheckItem({
    required this.id,
    required this.descripcion,
    required this.aprobado,
    this.detalle,
  });

  final String id;
  final String descripcion;
  final bool aprobado;
  final String? detalle;
}

/// Informe consolidado de la verificación de la alerta de uso continuo.
class UsageAlertVerificationResult {
  const UsageAlertVerificationResult({
    required this.items,
    required this.fecha,
  });

  final List<UsageAlertCheckItem> items;
  final DateTime fecha;

  int get total => items.length;
  int get aprobados => items.where((i) => i.aprobado).length;
  bool get todoAprobado => aprobados == total && total > 0;
}
