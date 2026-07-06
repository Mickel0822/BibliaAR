/// Entrada del historial de actividades de un perfil (BIAR-44).
///
/// Representa un intento registrado sobre una actividad educativa,
/// incluyendo resultado y número de intento para el panel de progreso.
class HistorialActividadEntry {
  const HistorialActividadEntry({
    this.id,
    required this.perfilId,
    required this.actividadId,
    required this.tituloActividad,
    required this.resultado,
    required this.intentoNumero,
    required this.fecha,
  });

  final int? id;
  final int perfilId;
  final int actividadId;
  final String tituloActividad;
  final String resultado;
  final int intentoNumero;
  final DateTime fecha;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'perfil_id': perfilId,
      'actividad_id': actividadId,
      'titulo_actividad': tituloActividad,
      'resultado': resultado,
      'intento_numero': intentoNumero,
      'fecha': fecha.toIso8601String(),
    };
  }

  factory HistorialActividadEntry.fromMap(Map<String, dynamic> map) {
    return HistorialActividadEntry(
      id: map['id'] as int?,
      perfilId: map['perfil_id'] as int,
      actividadId: map['actividad_id'] as int,
      tituloActividad: map['titulo_actividad'] as String? ?? 'Actividad',
      resultado: map['resultado'] as String,
      intentoNumero: map['intento_numero'] as int,
      fecha: DateTime.parse(map['fecha'] as String),
    );
  }
}
