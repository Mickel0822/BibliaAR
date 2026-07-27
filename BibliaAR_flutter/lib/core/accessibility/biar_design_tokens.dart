import 'package:flutter/material.dart';

// kguanoluisa, Tokens de diseno reutilizables para espaciado, radios, duraciones e iconografia, sin nuevas variables, 2026-07-23
class BiarSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class BiarRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

class BiarDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 350);
}

class BiarModuleIcons {
  static const IconData historias = Icons.auto_stories;
  static const IconData actividades = Icons.extension;
  static const IconData progreso = Icons.insights;
  static const IconData accesibilidad = Icons.accessibility_new;
  static const IconData tramites = Icons.account_balance;
  static const IconData docente = Icons.school;
  static const IconData arPreview = Icons.view_in_ar;
}
