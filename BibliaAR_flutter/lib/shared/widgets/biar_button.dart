import 'package:biblia_ar_flutter/core/accessibility/accessibility_sizes.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Boton accesible BIAR con tamano minimo de 48dp segun WCAG, sin nuevas variables, 2026-07-23
class BiarButton extends StatelessWidget {
  const BiarButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.touch_app, size: AccessibilitySizes.iconSize),
      label: Text(label),
    );

    if (expanded) {
      return SizedBox(
        width: double.infinity,
        height: AccessibilitySizes.buttonMinHeight,
        child: button,
      );
    }
    return SizedBox(
      height: AccessibilitySizes.buttonMinHeight,
      child: button,
    );
  }
}
