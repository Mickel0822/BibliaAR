class ResultadoActividad {
  const ResultadoActividad({
    this.id,
    required this.perfilId,
    required this.actividadId,
    required this.resultado,
    required this.intentoNumero,
    required this.fecha,
    this.updatedAt,
    this.syncStatus = 'local',
  });

  final int? id;
  final int perfilId;
  final int actividadId;
  final String resultado;
  final int intentoNumero;
  final DateTime fecha;
  final DateTime? updatedAt;
  final String syncStatus;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'perfil_id': perfilId,
      'actividad_id': actividadId,
      'resultado': resultado,
      'intento_numero': intentoNumero,
      'fecha': fecha.toIso8601String(),
      'updated_at': (updatedAt ?? fecha).toIso8601String(),
      'sync_status': syncStatus,
    };
  }

  factory ResultadoActividad.fromMap(Map<String, dynamic> map) {
    return ResultadoActividad(
      id: map['id'] as int?,
      perfilId: map['perfil_id'] as int,
      actividadId: map['actividad_id'] as int,
      resultado: map['resultado'] as String,
      intentoNumero: map['intento_numero'] as int,
      fecha: DateTime.parse(map['fecha'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      syncStatus: map['sync_status'] as String? ?? 'local',
    );
  }
}
