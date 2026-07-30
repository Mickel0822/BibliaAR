// kguanoluisa, Argumentos de navegacion para la vista previa AR simulada con soporte de voz, 2026-07-29
class ArPreviewArgs {
  const ArPreviewArgs({
    required this.vTitulo,
    required this.vOverlayAsset,
    this.vNarration = '',
  });

  final String vTitulo;
  final String vOverlayAsset;
  final String vNarration;
}
