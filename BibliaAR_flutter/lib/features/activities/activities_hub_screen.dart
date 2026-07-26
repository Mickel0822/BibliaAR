import 'dart:convert';

import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/core/feedback/multimodal_feedback.dart';
import 'package:biblia_ar_flutter/data/models/tipo_actividad.dart';
import 'package:biblia_ar_flutter/features/activities/actividad_provider.dart';
import 'package:biblia_ar_flutter/features/activities/widgets/completar_actividad_widget.dart';
import 'package:biblia_ar_flutter/features/activities/widgets/identificar_actividad_widget.dart';
import 'package:biblia_ar_flutter/features/activities/widgets/ordenar_actividad_widget.dart';
import 'package:biblia_ar_flutter/features/profiles/perfil_provider.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_loading_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// kguanoluisa, Hub de actividades biblicas con iconos por tipo, sin nuevas variables, 2026-07-23
class ActivitiesHubScreen extends StatefulWidget {
  const ActivitiesHubScreen({super.key, this.vLeccionId = 1});

  final int vLeccionId;

  @override
  State<ActivitiesHubScreen> createState() => _ActivitiesHubScreenState();
}

class _ActivitiesHubScreenState extends State<ActivitiesHubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActividadProvider>().cargarActividades(widget.vLeccionId);
    });
  }

  IconData _iconoPorTipo(TipoActividad tipo) {
    switch (tipo) {
      case TipoActividad.completar:
        return Icons.quiz;
      case TipoActividad.ordenar:
        return Icons.sort;
      case TipoActividad.identificar:
        return Icons.person_search;
      case TipoActividad.checklist:
        return Icons.checklist;
    }
  }

  Future<void> _registrarResultado(int actividadId, bool correcto) async {
    final perfil = context.read<PerfilProvider>().vPerfilActivo;
    if (perfil?.id == null) return;
    await context.read<ActividadProvider>().registrarIntento(
          perfilId: perfil!.id!,
          actividadId: actividadId,
          resultado: correcto ? 'correcto' : 'incorrecto',
        );
    if (!mounted) return;
    if (correcto) {
      await MultimodalFeedback.success(context);
    } else {
      await MultimodalFeedback.intento(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ActividadProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Actividades')),
      body: provider.vCargando
          ? const BiarLoadingView(vMensaje: 'Cargando actividades...')
          : ListView.builder(
              padding: const EdgeInsets.all(BiarSpacing.md),
              itemCount: provider.vActividades.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: BiarSpacing.md),
                    child: Row(
                      children: [
                        Icon(BiarModuleIcons.actividades, size: 40),
                        const SizedBox(width: BiarSpacing.sm),
                        Expanded(
                          child: Text(
                            'Repasa lo aprendido con actividades interactivas',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final actividad = provider.vActividades[index - 1];
                final payload =
                    jsonDecode(actividad.payloadJson) as Map<String, dynamic>;

                return Card(
                  margin: const EdgeInsets.only(bottom: BiarSpacing.md),
                  child: Padding(
                    padding: const EdgeInsets.all(BiarSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(_iconoPorTipo(actividad.tipo)),
                            const SizedBox(width: BiarSpacing.sm),
                            Text(
                              payload['titulo'] as String? ?? 'Actividad',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: BiarSpacing.sm),
                        _buildActividad(actividad.id!, actividad.tipo, payload),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildActividad(
    int actividadId,
    TipoActividad tipo,
    Map<String, dynamic> payload,
  ) {
    switch (tipo) {
      case TipoActividad.completar:
        return CompletarActividadWidget(
          payload: payload,
          onResultado: (correcto) => _registrarResultado(actividadId, correcto),
        );
      case TipoActividad.ordenar:
        return OrdenarActividadWidget(
          payload: payload,
          onResultado: (correcto) => _registrarResultado(actividadId, correcto),
        );
      case TipoActividad.identificar:
        return IdentificarActividadWidget(
          payload: payload,
          onResultado: (correcto) => _registrarResultado(actividadId, correcto),
        );
      case TipoActividad.checklist:
        return const Text('Actividad no disponible en esta versión.');
    }
  }
}
