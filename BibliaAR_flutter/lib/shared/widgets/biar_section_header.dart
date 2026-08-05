import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Encabezado de seccion con icono para agrupar contenido en pantallas, variables v_titulo y v_icono, 2026-07-23
class BiarSectionHeader extends StatelessWidget {
  const BiarSectionHeader({
    super.key,
    required this.vTitulo,
    required this.vIcono,
    this.vSubtitulo,
  });

  final String vTitulo;
  final IconData vIcono;
  final String? vSubtitulo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BiarSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(vIcono, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: BiarSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vTitulo, style: Theme.of(context).textTheme.titleLarge),
                if (vSubtitulo != null) ...[
                  const SizedBox(height: BiarSpacing.xs),
                  Text(vSubtitulo!, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
