import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_illustration.dart';
import 'package:biblia_ar_flutter/shared/widgets/floating_lse_player.dart';
import 'package:biblia_ar_flutter/shared/widgets/pictogram_bar.dart';
import 'package:biblia_ar_flutter/shared/widgets/subtitle_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// kguanoluisa, Retroalimentacion multimodal con metodo error visual LSE subtitulos y haptica, sin nuevas variables, 2026-07-29
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

  // kguanoluisa, Feedback de error accesible con dialogo visual panel LSE pictogramas y SnackBar, variables mensaje y pictogramas, 2026-07-29
  static Future<void> error(
    BuildContext context, {
    required String mensaje,
    List<String> pictogramas = const ['certificado'],
  }) async {
    HapticFeedback.heavyImpact();
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
              Icon(Icons.error_outline, size: 48, color: Theme.of(dialogContext).colorScheme.error),
              const SizedBox(height: BiarSpacing.md),
              Text(mensaje, textAlign: TextAlign.center),
              const SizedBox(height: BiarSpacing.sm),
              SubtitleOverlay(vTexto: mensaje),
              const SizedBox(height: BiarSpacing.sm),
              PictogramBar(vPictogramas: pictogramas),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 2500),
      ),
    );
  }

  // kguanoluisa, Feedback informativo accesible para certificado no encontrado con LSE y pictogramas, variables mensaje y pictogramas, 2026-07-29
  static Future<void> info(
    BuildContext context, {
    required String mensaje,
    List<String> pictogramas = const ['certificado', 'tramite'],
    VoidCallback? onAccion,
    String etiquetaAccion = 'Ver orientación',
  }) async {
    HapticFeedback.mediumImpact();
    if (!context.mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Stack(
          children: [
            AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off, size: 48, color: Theme.of(dialogContext).colorScheme.primary),
                  const SizedBox(height: BiarSpacing.md),
                  Text(mensaje, textAlign: TextAlign.center),
                  const SizedBox(height: BiarSpacing.sm),
                  SubtitleOverlay(vTexto: mensaje),
                  const SizedBox(height: BiarSpacing.sm),
                  PictogramBar(vPictogramas: pictogramas),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cerrar'),
                ),
                if (onAccion != null)
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      onAccion();
                    },
                    child: Text(etiquetaAccion),
                  ),
              ],
            ),
            FloatingLsePlayer(
              vTitulo: 'Certificado no encontrado',
              vDescripcion: mensaje,
              vVideoAsset: '',
            ),
          ],
        );
      },
    );
  }
}
