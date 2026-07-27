import 'package:biblia_ar_flutter/core/accessibility/accessibility_sizes.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Overlay de subtitulos sincronizados con contraste accesible, variable v_texto, 2026-07-23
class SubtitleOverlay extends StatelessWidget {
  const SubtitleOverlay({super.key, required this.vTexto});

  final String vTexto;

  @override
  Widget build(BuildContext context) {
    if (vTexto.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        vTexto,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: AccessibilitySizes.minFontSize,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    );
  }
}
