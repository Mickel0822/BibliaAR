import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/core/accessibility/biar_theme.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// kguanoluisa, Ilustracion con fallback visual si el asset no existe, variables v_assetPath, v_titulo y v_iconoFallback, 2026-07-23
class BiarIllustration extends StatelessWidget {
  const BiarIllustration({
    super.key,
    required this.vAssetPath,
    required this.vTitulo,
    this.vIconoFallback = Icons.image,
    this.vAltura = 220,
  });

  final String vAssetPath;
  final String vTitulo;
  final IconData vIconoFallback;
  final double vAltura;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(BiarRadius.lg),
      child: SizedBox(
        height: vAltura,
        width: double.infinity,
        child: vAssetPath.isEmpty
            ? _fallback(context)
            : Image.asset(
                vAssetPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallback(context),
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

// kguanoluisa, Animacion Lottie de exito con fallback a icono animado, variable v_assetPath, 2026-07-23
class BiarSuccessAnimation extends StatefulWidget {
  const BiarSuccessAnimation({
    super.key,
    this.vAssetPath = 'assets/lottie/success_check.json',
    this.vSize = 120,
  });

  final String vAssetPath;
  final double vSize;

  @override
  State<BiarSuccessAnimation> createState() => _BiarSuccessAnimationState();
}

class _BiarSuccessAnimationState extends State<BiarSuccessAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool vUsarFallback = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: BiarDurations.normal)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (vUsarFallback) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1.1).animate(_controller),
        child: Icon(Icons.check_circle, size: widget.vSize, color: BiarTheme.successColor),
      );
    }

    return SizedBox(
      width: widget.vSize,
      height: widget.vSize,
      child: Lottie.asset(
        widget.vAssetPath,
        repeat: false,
        errorBuilder: (_, __, ___) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => vUsarFallback = true);
          });
          return Icon(Icons.check_circle, size: widget.vSize, color: BiarTheme.successColor);
        },
      ),
    );
  }
}
