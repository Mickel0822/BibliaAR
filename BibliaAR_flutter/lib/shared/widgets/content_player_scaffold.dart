import 'dart:async';
import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/core/feedback/tts_service.dart';
import 'package:biblia_ar_flutter/data/models/configuracion_sensorial.dart';
import 'package:biblia_ar_flutter/data/models/fragmento_narrativo.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_button.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_illustration.dart';
import 'package:biblia_ar_flutter/shared/widgets/floating_lse_player.dart';
import 'package:biblia_ar_flutter/shared/widgets/pictogram_bar.dart';
import 'package:biblia_ar_flutter/shared/widgets/subtitle_overlay.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Scaffold del reproductor multimedia con soporte para interacciones en tiempo real sobre la escena 3D y auto-avance, 2026-07-29
class ContentPlayerScaffold extends StatefulWidget {
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

  @override
  State<ContentPlayerScaffold> createState() => _ContentPlayerScaffoldState();
}

class _ContentPlayerScaffoldState extends State<ContentPlayerScaffold> {
  Timer? _playbackTimer;
  String? _interaccionActiva;
  Timer? _interaccionTimer;
  bool _reproduciendoSoloEstaEscena = false;

  String get _ilustracionAsset {
    if (widget.vFragmento.ilustracionAsset.isNotEmpty) {
      return widget.vFragmento.ilustracionAsset;
    }
    return 'assets/illustrations/buen_samaritano/fragment_${widget.vFragmento.id}.png';
  }

  @override
  void initState() {
    super.initState();
    _checkAudioPlayback();
  }

  @override
  void didUpdateWidget(covariant ContentPlayerScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vReproduciendo != widget.vReproduciendo ||
        oldWidget.vFragmento.id != widget.vFragmento.id) {
      // Reinicia efectos y comprueba audio si cambia de escena o estado
      setState(() {
        _interaccionActiva = null;
        if (oldWidget.vFragmento.id != widget.vFragmento.id) {
          _reproduciendoSoloEstaEscena = false;
        }
      });
      _interaccionTimer?.cancel();
      _checkAudioPlayback();
    }
  }

  @override
  void dispose() {
    _stopAudioPlayback();
    _interaccionTimer?.cancel();
    super.dispose();
  }

  void _stopAudioPlayback() {
    TtsService.instance.stop();
    _playbackTimer?.cancel();
  }

  void _checkAudioPlayback() {
    _stopAudioPlayback();
    if (widget.vReproduciendo) {
      final config = widget.vConfiguracion;
      final bool audioActivo = config?.audioActivo ?? true;
      final double volumen = config?.volumenAudio ?? 1.0;
      final double velocidad = config?.velocidadAudio ?? 1.0;

      if (audioActivo) {
        TtsService.instance.speak(
          widget.vFragmento.textoSubtitulo,
          volume: volumen,
          rate: velocidad,
        );
      }

      final double duracionOriginal = widget.vFragmento.duracionMs.toDouble();
      final double duracionAjustada = duracionOriginal / (velocidad > 0 ? velocidad : 1.0);

      _playbackTimer = Timer(Duration(milliseconds: duracionAjustada.round()), () {
        if (widget.vReproduciendo) {
          if (widget.vEsUltimoFragmento) {
            widget.onAlternarReproduccion(); // Pausa al finalizar
            if (widget.onFinalizar != null) {
              widget.onFinalizar!();
            }
          } else {
            widget.onSiguiente();
          }
        }
      });
    }
  }

  void _playSoloEstaEscena() {
    _stopAudioPlayback();
    final config = widget.vConfiguracion;
    final bool audioActivo = config?.audioActivo ?? true;
    final double volumen = config?.volumenAudio ?? 1.0;
    final double velocidad = config?.velocidadAudio ?? 1.0;

    if (audioActivo) {
      TtsService.instance.speak(
        widget.vFragmento.textoSubtitulo,
        volume: volumen,
        rate: velocidad,
      );
    }

    final double duracionOriginal = widget.vFragmento.duracionMs.toDouble();
    final double duracionAjustada = duracionOriginal / (velocidad > 0 ? velocidad : 1.0);

    _playbackTimer = Timer(Duration(milliseconds: duracionAjustada.round()), () {
      if (mounted) {
        setState(() {
          _reproduciendoSoloEstaEscena = false;
        });
        if (widget.vEsUltimoFragmento && widget.onFinalizar != null) {
          widget.onFinalizar!();
        }
      }
    });
  }

  void _alternarReproducirEstaEscena() {
    if (_reproduciendoSoloEstaEscena) {
      _stopAudioPlayback();
      setState(() {
        _reproduciendoSoloEstaEscena = false;
      });
    } else {
      // Si estaba reproduciendo todo, pausamos primero
      if (widget.vReproduciendo) {
        widget.onAlternarReproduccion();
      }
      setState(() {
        _reproduciendoSoloEstaEscena = true;
      });
      _playSoloEstaEscena();
    }
  }

  void _alternarReproducirTodo() {
    if (_reproduciendoSoloEstaEscena) {
      setState(() {
        _reproduciendoSoloEstaEscena = false;
      });
      _stopAudioPlayback();
    }
    widget.onAlternarReproduccion();
  }

  void _onPictogramTap(String pictograma) {
    setState(() {
      _interaccionActiva = pictograma;
    });
    _interaccionTimer?.cancel();
    _interaccionTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _interaccionActiva = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.vTitulo)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(BiarSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: widget.vTotalFragmentos == 0
                  ? 0
                  : (widget.vIndiceActual + 1) / widget.vTotalFragmentos,
              borderRadius: BorderRadius.circular(BiarRadius.sm),
            ),
            const SizedBox(height: BiarSpacing.sm),
            Text(
              'Fragmento ${widget.vIndiceActual + 1} de ${widget.vTotalFragmentos}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: BiarSpacing.md),
            if (widget.vConfiguracion?.lseActivo ?? true)
              FloatingLsePlayer(
                vTitulo: widget.vFragmento.titulo,
                vDescripcion: widget.vFragmento.descripcion,
                vVideoAsset: widget.vFragmento.videoLseAsset,
                vInline: true,
              ),
            BiarIllustration(
              vAssetPath: _ilustracionAsset,
              vTitulo: widget.vFragmento.titulo,
              vIconoFallback: Icons.landscape,
              vFragmentoId: widget.vFragmento.id,
              vReproduciendo: widget.vReproduciendo || _reproduciendoSoloEstaEscena,
              vInteraccionActiva: _interaccionActiva,
            ),
            const SizedBox(height: BiarSpacing.md),
            if (widget.vConfiguracion?.subtitulosActivos ?? true)
              SubtitleOverlay(vTexto: widget.vFragmento.textoSubtitulo),
            const SizedBox(height: BiarSpacing.sm),
            if (widget.vConfiguracion?.pictogramasActivos ?? true)
              PictogramBar(
                vPictogramas: widget.vFragmento.pictogramas,
                onPictogramTap: _onPictogramTap,
              ),
            if (widget.onVerEnEspacio != null) ...[
              const SizedBox(height: BiarSpacing.md),
              BiarButton(
                label: 'Ver en tu espacio',
                icon: BiarModuleIcons.arPreview,
                onPressed: widget.onVerEnEspacio,
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
                    onPressed: widget.vEsPrimerFragmento ? null : widget.onAnterior,
                  ),
                ),
                const SizedBox(width: BiarSpacing.sm),
                Expanded(
                  child: BiarButton(
                    label: widget.vEsUltimoFragmento ? 'Finalizar' : 'Siguiente',
                    icon: widget.vEsUltimoFragmento ? Icons.check_circle_outline : Icons.skip_next,
                    expanded: false,
                    onPressed: widget.vEsUltimoFragmento 
                        ? widget.onFinalizar 
                        : widget.onSiguiente,
                  ),
                ),
              ],
            ),
            const SizedBox(height: BiarSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: BiarButton(
                    label: _reproduciendoSoloEstaEscena ? 'Pausar' : 'Reproducir esta escena',
                    icon: _reproduciendoSoloEstaEscena ? Icons.pause : Icons.play_arrow,
                    expanded: false,
                    onPressed: _alternarReproducirEstaEscena,
                  ),
                ),
                const SizedBox(width: BiarSpacing.sm),
                Expanded(
                  child: BiarButton(
                    label: widget.vReproduciendo ? 'Pausar todo' : 'Reproducir todo',
                    icon: widget.vReproduciendo ? Icons.pause : Icons.playlist_play,
                    expanded: false,
                    onPressed: _alternarReproducirTodo,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
