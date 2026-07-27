import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_illustration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// kguanoluisa, Retroalimentacion multimodal con animacion Lottie, haptica y SnackBar, sin nuevas variables, 2026-07-23
class MultimodalFeedback {
  static Future<void> success(BuildContext context, {String mensaje = '¡Lo lograste!'}) async {
    HapticFeedback.lightImpact();
    if (!context.mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BiarSuccessAnimation(),
              const SizedBox(height: BiarSpacing.md),
              Text(mensaje, textAlign: TextAlign.center),
            ],
          ),
        );
      },
    );

    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1800),
      ),
    );
  }

  static Future<void> intento(BuildContext context) async {
    HapticFeedback.selectionClick();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Inténtalo de nuevo, ¡tú puedes!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 1500),
      ),
    );
  }
}
