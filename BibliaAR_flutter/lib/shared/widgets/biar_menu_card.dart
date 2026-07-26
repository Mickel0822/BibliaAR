import 'package:biblia_ar_flutter/core/accessibility/accessibility_sizes.dart';
import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Tarjeta de menu accesible para el Home con icono, titulo y subtitulo, variables v_titulo, v_subtitulo, v_icono, 2026-07-23
class BiarMenuCard extends StatelessWidget {
  const BiarMenuCard({
    super.key,
    required this.vTitulo,
    required this.vSubtitulo,
    required this.vIcono,
    required this.onTap,
    this.vColor,
  });

  final String vTitulo;
  final String vSubtitulo;
  final IconData vIcono;
  final VoidCallback onTap;
  final Color? vColor;

  @override
  Widget build(BuildContext context) {
    final color = vColor ?? Theme.of(context).colorScheme.primary;

    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(BiarRadius.lg),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BiarRadius.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AccessibilitySizes.minTouchTarget * 2),
          child: Padding(
            padding: const EdgeInsets.all(BiarSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(vIcono, color: color, size: AccessibilitySizes.iconSize),
                ),
                const SizedBox(height: BiarSpacing.sm),
                Text(vTitulo, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: BiarSpacing.xs),
                Text(vSubtitulo, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
