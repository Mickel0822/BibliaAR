import 'dart:io';
import 'dart:math';
import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_illustration.dart';
import 'package:biblia_ar_flutter/shared/widgets/floating_lse_player.dart';
import 'package:biblia_ar_flutter/shared/widgets/pictogram_bar.dart';
import 'package:biblia_ar_flutter/shared/widgets/subtitle_overlay.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

// kguanoluisa, Retroalimentacion accesible multimodal con sintesis de sonido on-the-fly para aciertos/errores, 2026-07-29
class MultimodalFeedback {
  // kguanoluisa, Sintetizador de audio PCM WAV en memoria para evitar dependencias de archivos de sonido, 2026-07-29
  static Future<void> _playBeep(bool isSuccess) async {
    try {
      const int sampleRate = 8000;
      final double duration = isSuccess ? 0.35 : 0.45;
      final int numSamples = (sampleRate * duration).toInt();
      const int headerSize = 44;
      final int fileSize = headerSize + numSamples;

      final Uint8List wavBytes = Uint8List(fileSize);
      final ByteData byteData = ByteData.view(wavBytes.buffer);

      // Cabecera RIFF
      byteData.setUint32(0, 0x52494646, Endian.big); // "RIFF"
      byteData.setUint32(4, fileSize - 8, Endian.little);
      byteData.setUint32(8, 0x57415645, Endian.big); // "WAVE"

      // Sub-chunk formato
      byteData.setUint32(12, 0x666d7420, Endian.big); // "fmt "
      byteData.setUint32(16, 16, Endian.little);
      byteData.setUint16(20, 1, Endian.little); // PCM
      byteData.setUint16(22, 1, Endian.little); // Mono
      byteData.setUint32(24, sampleRate, Endian.little);
      byteData.setUint32(28, sampleRate, Endian.little); // Byte rate
      byteData.setUint16(32, 1, Endian.little);
      byteData.setUint16(34, 8, Endian.little); // 8-bit

      // Sub-chunk data
      byteData.setUint32(36, 0x64617461, Endian.big); // "data"
      byteData.setUint32(40, numSamples, Endian.little);

      // Generar muestras senoidales/cuadradas
      if (isSuccess) {
        // Melodía agradable: C5 (523Hz) seguido de E5 (659Hz)
        const double f1 = 523.25;
        const double f2 = 659.25;
        final int half = numSamples ~/ 2;
        for (int i = 0; i < numSamples; i++) {
          final double freq = i < half ? f1 : f2;
          final double t = i / sampleRate;
          final double val = sin(2 * pi * freq * t);
          wavBytes[headerSize + i] = (128 + 90 * val).toInt();
        }
      } else {
        // Zumbido de error: C3 (130Hz) onda cuadrada con desvanecimiento
        const double freq = 130.81;
        for (int i = 0; i < numSamples; i++) {
          final double t = i / sampleRate;
          final double volumeMultiplier = (1.0 - (i / numSamples));
          final double val = sin(2 * pi * freq * t) > 0 ? 0.35 : -0.35;
          wavBytes[headerSize + i] = (128 + 90 * val * volumeMultiplier).toInt();
        }
      }

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/biar_sound_${isSuccess ? "ok" : "err"}.wav');
      await file.writeAsBytes(wavBytes, flush: true);

      final player = AudioPlayer();
      await player.setFilePath(file.path);
      await player.play();
      player.processingStateStream.listen((state) {
        if (state == ProcessingState.completed) {
          player.dispose();
        }
      });
    } catch (e) {
      debugPrint("Error al reproducir audio sintetizado: $e");
    }
  }

  static Future<void> success(BuildContext context, {String mensaje = '¡Lo lograste!'}) async {
    HapticFeedback.lightImpact();
    _playBeep(true); // Reproduce sonido agradable de acierto
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

  static Future<void> intento(BuildContext context, {String mensaje = 'Inténtalo de nuevo, ¡tú puedes!'}) async {
    HapticFeedback.selectionClick();
    _playBeep(false); // Reproduce sonido de error
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
              const BiarErrorAnimation(),
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
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  // kguanoluisa, Feedback de error accesible con dialogo visual, animación nativa, panel LSE, pictogramas y SnackBar, 2026-07-29
  static Future<void> error(
    BuildContext context, {
    required String mensaje,
    List<String> pictogramas = const ['certificado'],
  }) async {
    HapticFeedback.heavyImpact();
    _playBeep(false); // Reproduce sonido de error/advertencia
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
              const BiarErrorAnimation(),
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

  // kguanoluisa, Feedback informativo accesible para certificado no encontrado con LSE y pictogramas, 2026-07-29
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
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingLsePlayer(
                vTitulo: 'Certificado no encontrado',
                vDescripcion: mensaje,
                vVideoAsset: '',
                vInline: true,
              ),
              const SizedBox(height: BiarSpacing.sm),
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
        );
      },
    );
  }
}
