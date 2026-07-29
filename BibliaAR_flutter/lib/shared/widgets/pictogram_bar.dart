import 'package:biblia_ar_flutter/core/accessibility/biar_pictogram_icons.dart';
import 'package:biblia_ar_flutter/core/feedback/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// kguanoluisa, Barra de pictogramas interactivos sincronizados con el fragmento narrativo, variable v_pictogramas, 2026-07-29
class PictogramBar extends StatelessWidget {
  const PictogramBar({
    super.key,
    required this.vPictogramas,
    this.onPictogramTap,
  });

  final List<String> vPictogramas;
  final ValueChanged<String>? onPictogramTap;

  @override
  Widget build(BuildContext context) {
    if (vPictogramas.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: vPictogramas.map((pictograma) {
            return PictogramItem(
              vPictograma: pictograma,
              onTap: onPictogramTap,
            );
          }).toList(),
        ),
      ),
    );
  }
}

// kguanoluisa, Pictograma interactivo con animacion de escala, haptica, TTS e invocacion de onTap, variable vPictograma, 2026-07-29
class PictogramItem extends StatefulWidget {
  const PictogramItem({
    super.key,
    required this.vPictograma,
    this.onTap,
  });

  final String vPictograma;
  final ValueChanged<String>? onTap;

  @override
  State<PictogramItem> createState() => _PictogramItemState();
}

class _PictogramItemState extends State<PictogramItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() async {
    HapticFeedback.lightImpact();
    // Ejecuta animacion de rebote (escala)
    _controller.forward().then((_) => _controller.reverse());
    
    // Pronuncia el pictograma en español de forma audible
    final etiqueta = BiarPictogramIcons.etiquetaPara(widget.vPictograma);
    await TtsService.instance.speak(etiqueta, volume: 1.0, rate: 0.9);

    // Invoca el callback de interaccion
    widget.onTap?.call(widget.vPictograma);
  }

  @override
  Widget build(BuildContext context) {
    final etiqueta = BiarPictogramIcons.etiquetaPara(widget.vPictograma);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  BiarPictogramIcons.iconoPara(widget.vPictograma),
                  size: 36,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 4),
                Text(
                  etiqueta,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
