import 'dart:math';
import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Ilustracion con soporte de escenas animadas 3D e interaccion por pictogramas, variables vFragmentoId, vReproduciendo y vInteraccionActiva, 2026-07-29
class BiarIllustration extends StatelessWidget {
  const BiarIllustration({
    super.key,
    required this.vAssetPath,
    required this.vTitulo,
    this.vIconoFallback = Icons.image,
    this.vAltura = 340,
    this.vFragmentoId,
    this.vReproduciendo = false,
    this.vInteraccionActiva,
  });

  final String vAssetPath;
  final String vTitulo;
  final IconData vIconoFallback;
  final double vAltura;
  final int? vFragmentoId;
  final bool vReproduciendo;
  final String? vInteraccionActiva;

  @override
  Widget build(BuildContext context) {
    final esBuenSamaritano = vAssetPath.contains('buen_samaritano');

    return ClipRRect(
      borderRadius: BorderRadius.circular(BiarRadius.lg),
      child: SizedBox(
        height: vAltura,
        width: double.infinity,
        child: esBuenSamaritano
            ? BuenSamaritanoAnimatedScene(
                vFragmentoId: vFragmentoId ?? 1,
                vReproduciendo: vReproduciendo,
                vInteraccionActiva: vInteraccionActiva,
              )
            : vAssetPath.isEmpty
                ? _fallback(context)
                : Image.asset(
                    vAssetPath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _fallback(context),
                  ),
      ),
    );
  }

  Widget _fallback(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(vIconoFallback, size: 72, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: BiarSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: BiarSpacing.md),
            child: Text(vTitulo, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

// kguanoluisa, Escena animada interactiva para El Buen Samaritano con efectos de camara, sacudidas y particulas, 2026-07-29
class BuenSamaritanoAnimatedScene extends StatefulWidget {
  const BuenSamaritanoAnimatedScene({
    super.key,
    required this.vFragmentoId,
    required this.vReproduciendo,
    this.vInteraccionActiva,
  });

  final int vFragmentoId;
  final bool vReproduciendo;
  final String? vInteraccionActiva;

  @override
  State<BuenSamaritanoAnimatedScene> createState() => _BuenSamaritanoAnimatedSceneState();
}

class _BuenSamaritanoAnimatedSceneState extends State<BuenSamaritanoAnimatedScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.vReproduciendo || widget.vInteraccionActiva != null) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant BuenSamaritanoAnimatedScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.vReproduciendo || widget.vInteraccionActiva != null) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      if (_controller.isAnimating && widget.vInteraccionActiva == null) {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value;

            // 1. Efecto Ken Burns (paneo/zoom suave en reproduccion)
            final double scale = 1.0 + (widget.vReproduciendo ? (sin(t * pi) * 0.08) : 0.0);
            final double dx = widget.vReproduciendo ? (cos(t * 2 * pi) * 10) : 0.0;
            final double dy = widget.vReproduciendo ? (sin(t * 2 * pi) * 5) : 0.0;

            // 2. Efecto de sacudida (shaking por golpe/herido)
            final double shakeOffset = widget.vInteraccionActiva == 'herido' ? (sin(t * 20 * pi) * 8) : 0.0;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Imagen 3D principal con transformaciones de camara y sacudida
                Transform.translate(
                  offset: Offset(dx + shakeOffset, dy),
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/illustrations/buen_samaritano/fragment_${widget.vFragmentoId}.png',
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, _, _) => _fallbackStatic(context),
                    ),
                  ),
                ),

                // 3. Efectos especiales y superposiciones interactivas
                if (widget.vInteraccionActiva == 'herido')
                  Container(
                    color: Colors.red.withValues(alpha: (sin(t * 10 * pi).abs() * 0.25).clamp(0.0, 0.25)),
                  ),

                if (widget.vInteraccionActiva == 'camino' || widget.vReproduciendo)
                  _buildBreezeParticles(t, width),

                if (widget.vInteraccionActiva == 'ayudar' || widget.vInteraccionActiva == 'samaritano')
                  _buildCompassionHearts(t, width),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBreezeParticles(double t, double width) {
    final double x1 = ((t * 2.0 + 0.1) % 1.0) * (width + 100) - 50;
    final double x2 = ((t * 1.5 + 0.5) % 1.0) * (width + 100) - 50;

    return Stack(
      children: [
        Positioned(
          bottom: 40,
          left: x1,
          child: Icon(Icons.air, color: Colors.white.withValues(alpha: 0.4), size: 28),
        ),
        Positioned(
          bottom: 20,
          left: x2,
          child: Icon(Icons.air, color: Colors.white.withValues(alpha: 0.3), size: 22),
        ),
      ],
    );
  }

  Widget _buildCompassionHearts(double t, double width) {
    final double h1y = ((t + 0.0) % 1.0) * 120;
    final double h1x = sin(t * 2 * pi) * 25;
    final double h2y = ((t + 0.5) % 1.0) * 120;
    final double h2x = cos(t * 3 * pi) * 30;

    return Stack(
      children: [
        Positioned(
          bottom: h1y,
          left: width * 0.5 + h1x,
          child: Opacity(
            opacity: (1.0 - (h1y / 120)).clamp(0.0, 1.0),
            child: const Icon(Icons.favorite, color: Colors.pink, size: 28),
          ),
        ),
        Positioned(
          bottom: h2y + 10,
          left: width * 0.4 + h2x,
          child: Opacity(
            opacity: (1.0 - (h2y / 120)).clamp(0.0, 1.0),
            child: const Icon(Icons.favorite, color: Colors.redAccent, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _fallbackStatic(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: const Center(
        child: Icon(Icons.landscape, size: 72, color: Colors.grey),
      ),
    );
  }
}

// kguanoluisa, Animación nativa premium de éxito con rebote y halo brillante para feedback accesible, 2026-07-29
class BiarSuccessAnimation extends StatefulWidget {
  const BiarSuccessAnimation({
    super.key,
    this.vAssetPath = '',
    this.vSize = 110,
  });

  final String vAssetPath;
  final double vSize;

  @override
  State<BiarSuccessAnimation> createState() => _BiarSuccessAnimationState();
}

class _BiarSuccessAnimationState extends State<BiarSuccessAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.vSize,
      height: widget.vSize,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Halo luminoso exterior
              Transform.scale(
                scale: _scaleAnimation.value * 1.25,
                child: Container(
                  width: widget.vSize * 0.8,
                  height: widget.vSize * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withValues(alpha: 0.15),
                  ),
                ),
              ),
              // Círculo verde principal
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: widget.vSize * 0.65,
                  height: widget.vSize * 0.65,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              // Ícono de check
              Transform.scale(
                scale: _checkAnimation.value,
                child: Icon(
                  Icons.check,
                  size: widget.vSize * 0.45,
                  color: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// kguanoluisa, Animación nativa premium de error con sacudida horizontal (shake) y halo rojo para feedback accesible, 2026-07-29
class BiarErrorAnimation extends StatefulWidget {
  const BiarErrorAnimation({
    super.key,
    this.vSize = 110,
  });

  final double vSize;

  @override
  State<BiarErrorAnimation> createState() => _BiarErrorAnimationState();
}

class _BiarErrorAnimationState extends State<BiarErrorAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.vSize,
      height: widget.vSize,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          // Sacudida horizontal que decrece con el tiempo
          final shake = sin(t * 4 * pi) * 8 * (1.0 - t);
          return Transform.translate(
            offset: Offset(shake, 0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Halo luminoso rojo
                Transform.scale(
                  scale: _scaleAnimation.value * 1.25,
                  child: Container(
                    width: widget.vSize * 0.8,
                    height: widget.vSize * 0.8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                // Círculo rojo principal
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: widget.vSize * 0.65,
                    height: widget.vSize * 0.65,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
                // Ícono de cerrar (X)
                Icon(
                  Icons.close,
                  size: widget.vSize * 0.45,
                  color: Colors.white,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
