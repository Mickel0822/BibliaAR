class ConfiguracionSensorial {
  const ConfiguracionSensorial({
    required this.perfilId,
    this.lseActivo = true,
    this.subtitulosActivos = true,
    this.audioActivo = true,
    this.pictogramasActivos = true,
    this.velocidadAudio = 1.0,
    this.volumenAudio = 1.0,
    this.updatedAt,
    this.syncStatus = 'local',
  });

  final int perfilId;
  final bool lseActivo;
  final bool subtitulosActivos;
  final bool audioActivo;
  final bool pictogramasActivos;
  final double velocidadAudio;
  final double volumenAudio;
  final DateTime? updatedAt;
  final String syncStatus;

  ConfiguracionSensorial copyWith({
    int? perfilId,
    bool? lseActivo,
    bool? subtitulosActivos,
    bool? audioActivo,
    bool? pictogramasActivos,
    double? velocidadAudio,
    double? volumenAudio,
    DateTime? updatedAt,
    String? syncStatus,
  }) {
    return ConfiguracionSensorial(
      perfilId: perfilId ?? this.perfilId,
      lseActivo: lseActivo ?? this.lseActivo,
      subtitulosActivos: subtitulosActivos ?? this.subtitulosActivos,
      audioActivo: audioActivo ?? this.audioActivo,
      pictogramasActivos: pictogramasActivos ?? this.pictogramasActivos,
      velocidadAudio: velocidadAudio ?? this.velocidadAudio,
      volumenAudio: volumenAudio ?? this.volumenAudio,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'perfil_id': perfilId,
      'lse_activo': lseActivo ? 1 : 0,
      'subtitulos_activos': subtitulosActivos ? 1 : 0,
      'audio_activo': audioActivo ? 1 : 0,
      'pictogramas_activos': pictogramasActivos ? 1 : 0,
      'velocidad_audio': velocidadAudio,
      'volumen_audio': volumenAudio,
      'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
      'sync_status': syncStatus,
    };
  }

  factory ConfiguracionSensorial.fromMap(Map<String, dynamic> map) {
    return ConfiguracionSensorial(
      perfilId: map['perfil_id'] as int,
      lseActivo: (map['lse_activo'] as int) == 1,
      subtitulosActivos: (map['subtitulos_activos'] as int) == 1,
      audioActivo: (map['audio_activo'] as int) == 1,
      pictogramasActivos: (map['pictogramas_activos'] as int) == 1,
      velocidadAudio: (map['velocidad_audio'] as num).toDouble(),
      volumenAudio: (map['volumen_audio'] as num).toDouble(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      syncStatus: map['sync_status'] as String? ?? 'local',
    );
  }
}
