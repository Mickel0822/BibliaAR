class FragmentoNarrativo {
  const FragmentoNarrativo({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.ilustracionAsset,
    required this.videoLseAsset,
    required this.audioAsset,
    required this.duracionMs,
    this.pictogramas = const [],
    this.textoSubtitulo = '',
  });

  final int id;
  final String titulo;
  final String descripcion;
  final String ilustracionAsset;
  final String videoLseAsset;
  final String audioAsset;
  final int duracionMs;
  final List<String> pictogramas;
  final String textoSubtitulo;

  factory FragmentoNarrativo.fromMap(Map<String, dynamic> map) {
    return FragmentoNarrativo(
      id: map['id'] as int,
      titulo: map['titulo'] as String? ?? '',
      descripcion: map['descripcion'] as String? ?? '',
      ilustracionAsset: map['ilustracionAsset'] as String? ?? '',
      videoLseAsset: map['videoLseAsset'] as String? ?? '',
      audioAsset: map['audioAsset'] as String? ?? '',
      duracionMs: map['duracionMs'] as int? ?? 4000,
      pictogramas: (map['pictogramas'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          const [],
      textoSubtitulo: map['texto'] as String? ?? map['descripcion'] as String? ?? '',
    );
  }
}
