import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_button.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Vista de error con mensaje y boton reintentar, variables v_mensaje y onReintentar, 2026-07-23
class BiarErrorView extends StatelessWidget {
  const BiarErrorView({
    super.key,
    required this.vMensaje,
    required this.onReintentar,
  });

  final String vMensaje;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(BiarSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: BiarSpacing.md),
            Text(vMensaje, textAlign: TextAlign.center),
            const SizedBox(height: BiarSpacing.md),
            BiarButton(
              label: 'Reintentar',
              icon: Icons.refresh,
              onPressed: onReintentar,
              expanded: false,
            ),
          ],
        ),
      ),
    );
  }
}
