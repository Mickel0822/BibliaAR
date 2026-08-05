class Leccion {
  const Leccion({
    this.id,
    required this.titulo,
    required this.referenciaBiblica,
    required this.contenidoMultimediaPath,
    this.categoria = 'biblico',
    this.orden = 0,
    this.historiaTexto = '',
    this.versiculoReferencia = '',
    this.versiculoTexto = '',
    this.pictograma = 'historias',
    this.updatedAt,
    this.syncStatus = 'local',
  });

  final int? id;
  final String titulo;
  final String referenciaBiblica;
  final String contenidoMultimediaPath;
  final String categoria;
  final int orden;
  final String historiaTexto;
  final String versiculoReferencia;
  final String versiculoTexto;
  final String pictograma;
  final DateTime? updatedAt;
  final String syncStatus;

  bool get esLeccionDocente => historiaTexto.isNotEmpty;

  String get versiculoDisplay =>
      versiculoReferencia.isNotEmpty ? versiculoReferencia : referenciaBiblica;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'titulo': titulo,
      'referencia_biblica': referenciaBiblica,
      'contenido_multimedia_path': contenidoMultimediaPath,
      'categoria': categoria,
      'orden': orden,
      'historia_texto': historiaTexto,
      'versiculo_referencia': versiculoReferencia,
      'versiculo_texto': versiculoTexto,
      'pictograma': pictograma,
      'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
      'sync_status': syncStatus,
    };
  }

  factory Leccion.fromMap(Map<String, dynamic> map) {
    return Leccion(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      referenciaBiblica: map['referencia_biblica'] as String,
      contenidoMultimediaPath: map['contenido_multimedia_path'] as String,
      categoria: map['categoria'] as String? ?? 'biblico',
      orden: map['orden'] as int? ?? 0,
      historiaTexto: map['historia_texto'] as String? ?? '',
      versiculoReferencia: map['versiculo_referencia'] as String? ?? '',
      versiculoTexto: map['versiculo_texto'] as String? ?? '',
      pictograma: map['pictograma'] as String? ?? 'historias',
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      syncStatus: map['sync_status'] as String? ?? 'local',
    );
  }
}
