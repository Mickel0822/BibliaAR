import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/data/models/configuracion_sensorial.dart';
import 'package:biblia_ar_flutter/data/models/fragmento_narrativo.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_button.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_illustration.dart';
import 'package:biblia_ar_flutter/shared/widgets/floating_lse_player.dart';
import 'package:biblia_ar_flutter/shared/widgets/pictogram_bar.dart';
import 'package:biblia_ar_flutter/shared/widgets/subtitle_overlay.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Scaffold reutilizable del reproductor de contenido con LSE, subtitulos y pictogramas, variables v_titulo, v_fragmento y v_configuracion, 2026-07-23
class ContentPlayerScaffold extends StatelessWidget {
  const ContentPlayerScaffold({
    super.key,
    required this.vTitulo,
    required this.vFragmento,
    required this.vIndiceActual,
    required this.vTotalFragmentos,
    required this.vReproduciendo,
    required this.vConfiguracion,
    required this.onAnterior,
    required this.onSiguiente,
    required this.onAlternarReproduccion,
    this.onFinalizar,
    this.onVerEnEspacio,
    this.vTextoBotonFinal = '¡Actividad lista!',
    this.vEsUltimoFragmento = false,
    this.vEsPrimerFragmento = false,
  });

  final String vTitulo;
  final FragmentoNarrativo vFragmento;
  final int vIndiceActual;
  final int vTotalFragmentos;
  final bool vReproduciendo;
  final ConfiguracionSensorial? vConfiguracion;
  final VoidCallback onAnterior;
  final VoidCallback onSiguiente;
  final VoidCallback onAlternarReproduccion;
  final VoidCallback? onFinalizar;
  final VoidCallback? onVerEnEspacio;
  final String vTextoBotonFinal;
  final bool vEsUltimoFragmento;
  final bool vEsPrimerFragmento;

  String get _ilustracionAsset {
    if (vFragmento.ilustracionAsset.isNotEmpty) {
      return vFragmento.ilustracionAsset;
    }
    return 'assets/illustrations/buen_samaritano/fragment_${vFragmento.id}.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(vTitulo)),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(BiarSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(
                  value: vTotalFragmentos == 0
                      ? 0
                      : (vIndiceActual + 1) / vTotalFragmentos,
                  borderRadius: BorderRadius.circular(BiarRadius.sm),
                ),
                const SizedBox(height: BiarSpacing.sm),
                Text(
                  'Fragmento ${vIndiceActual + 1} de $vTotalFragmentos',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: BiarSpacing.md),
                BiarIllustration(
                  vAssetPath: _ilustracionAsset,
                  vTitulo: vFragmento.titulo,
                  vIconoFallback: Icons.landscape,
                ),
                const SizedBox(height: BiarSpacing.sm),
                Text(vFragmento.descripcion, textAlign: TextAlign.center),
                const SizedBox(height: BiarSpacing.md),
                if (vConfiguracion?.subtitulosActivos ?? true)
                  SubtitleOverlay(vTexto: vFragmento.textoSubtitulo),
                const SizedBox(height: BiarSpacing.sm),
                if (vConfiguracion?.pictogramasActivos ?? true)
                  PictogramBar(vPictogramas: vFragmento.pictogramas),
                if (onVerEnEspacio != null) ...[
                  const SizedBox(height: BiarSpacing.md),
                  BiarButton(
                    label: 'Ver en tu espacio',
                    icon: BiarModuleIcons.arPreview,
                    onPressed: onVerEnEspacio,
                  ),
                ],
                const SizedBox(height: 80),
                Row(
                  children: [
                    Expanded(
                      child: BiarButton(
                        label: 'Anterior',
                        icon: Icons.skip_previous,
                        expanded: false,
                        onPressed: vEsPrimerFragmento ? null : onAnterior,
                      ),
                    ),
                    const SizedBox(width: BiarSpacing.sm),
                    Expanded(
                      child: BiarButton(
                        label: vReproduciendo ? 'Pausar' : 'Reproducir',
                        icon: vReproduciendo ? Icons.pause : Icons.play_arrow,
                        expanded: false,
                        onPressed: onAlternarReproduccion,
                      ),
                    ),
                    const SizedBox(width: BiarSpacing.sm),
                    Expanded(
                      child: BiarButton(
                        label: 'Siguiente',
                        icon: Icons.skip_next,
                        expanded: false,
                        onPressed: vEsUltimoFragmento ? null : onSiguiente,
                      ),
                    ),
                  ],
                ),
                if (vEsUltimoFragmento && onFinalizar != null) ...[
                  const SizedBox(height: BiarSpacing.sm),
                  BiarButton(
                    label: vTextoBotonFinal,
                    icon: Icons.celebration,
                    onPressed: onFinalizar,
                  ),
                ],
              ],
            ),
          ),
          if (vConfiguracion?.lseActivo ?? true)
            FloatingLsePlayer(
              vTitulo: vFragmento.titulo,
              vDescripcion: vFragmento.descripcion,
              vVideoAsset: vFragmento.videoLseAsset,
            ),
        ],
      ),
    );
  }
}
