import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Mapa centralizado de pictogramas incluyendo tipos de discapacidad CONADIS, sin nuevas variables, 2026-07-29
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
        return Icons.healing_rounded;
      case 'samaritano':
        return Icons.favorite_rounded;
      case 'ayudar':
        return Icons.volunteer_activism_rounded;
      case 'camino':
        return Icons.route_rounded;
      case 'tramite':
        return Icons.assignment_rounded;
      case 'municipio':
        return Icons.account_balance_rounded;
      case 'cedula':
        return Icons.badge_rounded;
      case 'documento':
        return Icons.description_rounded;
      case 'entrega':
        return Icons.outbox_rounded;
      case 'certificado':
        return Icons.verified_rounded;
      case 'auditiva':
        return Icons.hearing_rounded;
      case 'visual':
        return Icons.visibility_rounded;
      case 'motriz':
        return Icons.accessible_rounded;
      case 'intelectual':
        return Icons.psychology_rounded;
      case 'multiple':
        return Icons.groups_rounded;
      case 'conadis':
        return Icons.health_and_safety_rounded;
      default:
        return Icons.auto_stories_rounded;
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
      case 'auditiva':
        return 'Auditiva';
      case 'visual':
        return 'Visual';
      case 'motriz':
        return 'Motriz';
      case 'intelectual':
        return 'Intelectual';
      case 'multiple':
        return 'Múltiple';
      case 'conadis':
        return 'CONADIS';
      case 'certificado':
        return 'Certificado';
      case 'tramite':
        return 'Trámite';
      case 'documento':
        return 'Documento';
      case 'municipio':
        return 'Municipio';
      default:
        return pictograma;
    }
  }
}
