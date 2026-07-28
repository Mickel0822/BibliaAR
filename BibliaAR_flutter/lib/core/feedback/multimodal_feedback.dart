import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/shared/widgets/pictogram_bar.dart';
import 'package:biblia_ar_flutter/shared/widgets/subtitle_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// kguanoluisa, Retroalimentacion multimodal con metodo error para validacion de formato CONADIS, sin nuevas variables, 2026-07-28
class MultimodalFeedback {
  static Future<void> success(BuildContext context, {String mensaje = '¡Lo lograste!'}) async {
    HapticFeedback.lightImpact();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  static Future<void> intento(BuildContext context) async {
    HapticFeedback.selectionClick();
  }

  // kguanoluisa, Feedback de error accesible para formato invalido de certificado CONADIS, variables mensaje y pictogramas, 2026-07-28
  static Future<void> error(
    BuildContext context, {
    required String mensaje,
    List<String> pictogramas = const ['certificado'],
  }) async {
    HapticFeedback.heavyImpact();
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Theme.of(dialogContext).colorScheme.error),
            const SizedBox(height: BiarSpacing.md),
            Text(mensaje, textAlign: TextAlign.center),
            SubtitleOverlay(vTexto: mensaje),
            PictogramBar(vPictogramas: pictogramas),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Entendido')),
        ],
      ),
    );
  }
}
