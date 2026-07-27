import 'package:biblia_ar_flutter/core/accessibility/accessibility_sizes.dart';
import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Tarjeta unificada de leccion para Home del nino y panel docente, variables v_titulo, v_versiculoReferencia, v_icono, v_estadoLabel, 2026-07-23
class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.vTitulo,
    required this.vVersiculoReferencia,
    required this.vIcono,
    required this.onTap,
    this.vEstadoLabel,
    this.vColor,
  });

  final String vTitulo;
  final String vVersiculoReferencia;
  final IconData vIcono;
  final VoidCallback onTap;
  final String? vEstadoLabel;
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
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(vIcono, color: color, size: AccessibilitySizes.iconSize),
                ),
                const SizedBox(width: BiarSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(vTitulo, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: BiarSpacing.xs),
                      Text(
                        vVersiculoReferencia,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (vEstadoLabel != null) ...[
                  const SizedBox(width: BiarSpacing.sm),
                  Chip(label: Text(vEstadoLabel!)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
