import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Mapa centralizado de pictogramas a iconos para lecciones y barras visuales, sin nuevas variables, 2026-07-23
class BiarPictogramIcons {
  static const List<String> opcionesDocente = [
    'historias',
    'samaritano',
    'ayudar',
    'camino',
    'herido',
  ];

  static IconData iconoPara(String pictograma) {
    switch (pictograma) {
      case 'historias':
        return BiarModuleIcons.historias;
      case 'herido':
        return Icons.healing;
      case 'samaritano':
        return Icons.favorite;
      case 'ayudar':
        return Icons.volunteer_activism;
      case 'camino':
        return Icons.route;
      case 'tramite':
        return Icons.assignment;
      case 'municipio':
        return Icons.account_balance;
      case 'cedula':
        return Icons.badge;
      case 'documento':
        return Icons.description;
      case 'entrega':
        return Icons.outbox;
      case 'certificado':
        return Icons.verified;
      default:
        return Icons.auto_stories;
    }
  }

  static String etiquetaPara(String pictograma) {
    switch (pictograma) {
      case 'historias':
        return 'Historias';
      case 'herido':
        return 'Herido';
      case 'samaritano':
        return 'Samaritano';
      case 'ayudar':
        return 'Ayudar';
      case 'camino':
        return 'Camino';
      default:
        return pictograma;
    }
  }
}
