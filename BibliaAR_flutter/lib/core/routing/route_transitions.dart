import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Transiciones fade-slide reutilizables para navegacion entre pantallas, sin nuevas variables, 2026-07-23
class RouteTransitions {
  static Route<T> fadeSlide<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: BiarDurations.normal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offsetAnimation, child: child),
        );
      },
    );
  }
}
