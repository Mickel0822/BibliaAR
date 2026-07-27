import 'package:biblia_ar_flutter/data/models/estado_progreso.dart';

class Progreso {
  const Progreso({
    this.id,
    required this.perfilId,
    required this.leccionId,
    required this.estado,
    required this.fecha,
    this.updatedAt,
    this.syncStatus = 'local',
  });

  final int? id;
  final int perfilId;
  final int leccionId;
  final EstadoProgreso estado;
  final DateTime fecha;
  final DateTime? updatedAt;
  final String syncStatus;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'perfil_id': perfilId,
      'leccion_id': leccionId,
      'estado': estado.value,
      'fecha': fecha.toIso8601String(),
      'updated_at': (updatedAt ?? fecha).toIso8601String(),
      'sync_status': syncStatus,
    };
  }

  factory Progreso.fromMap(Map<String, dynamic> map) {
    return Progreso(
      id: map['id'] as int?,
      perfilId: map['perfil_id'] as int,
      leccionId: map['leccion_id'] as int,
      estado: EstadoProgreso.fromValue(map['estado'] as String),
      fecha: DateTime.parse(map['fecha'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      syncStatus: map['sync_status'] as String? ?? 'local',
    );
  }
}
