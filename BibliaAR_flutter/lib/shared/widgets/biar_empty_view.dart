import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_button.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Vista de estado vacio con mensaje y accion opcional, variables v_mensaje, v_icono y v_accionLabel, 2026-07-23
class BiarEmptyView extends StatelessWidget {
  const BiarEmptyView({
    super.key,
    required this.vMensaje,
    this.vIcono = Icons.inbox_outlined,
    this.vAccionLabel,
    this.onAccion,
  });

  final String vMensaje;
  final IconData vIcono;
  final String? vAccionLabel;
  final VoidCallback? onAccion;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(BiarSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(vIcono, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: BiarSpacing.md),
            Text(vMensaje, textAlign: TextAlign.center),
            if (vAccionLabel != null && onAccion != null) ...[
              const SizedBox(height: BiarSpacing.md),
              BiarButton(label: vAccionLabel!, onPressed: onAccion, expanded: false),
            ],
          ],
        ),
      ),
    );
  }
}
