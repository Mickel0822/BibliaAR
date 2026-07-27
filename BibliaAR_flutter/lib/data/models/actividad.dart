import 'package:biblia_ar_flutter/data/models/tipo_actividad.dart';

class Actividad {
  const Actividad({
    this.id,
    required this.leccionId,
    required this.tipo,
    required this.payloadJson,
    this.updatedAt,
    this.syncStatus = 'local',
  });

  final int? id;
  final int leccionId;
  final TipoActividad tipo;
  final String payloadJson;
  final DateTime? updatedAt;
  final String syncStatus;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'leccion_id': leccionId,
      'tipo': tipo.value,
      'payload_json': payloadJson,
      'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
      'sync_status': syncStatus,
    };
  }

  factory Actividad.fromMap(Map<String, dynamic> map) {
    return Actividad(
      id: map['id'] as int?,
      leccionId: map['leccion_id'] as int,
      tipo: TipoActividad.fromValue(map['tipo'] as String),
      payloadJson: map['payload_json'] as String,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      syncStatus: map['sync_status'] as String? ?? 'local',
    );
  }
}
