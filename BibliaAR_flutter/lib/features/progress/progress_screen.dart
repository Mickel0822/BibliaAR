import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/core/accessibility/biar_pictogram_icons.dart';
import 'package:biblia_ar_flutter/core/di/repository_provider.dart';
import 'package:biblia_ar_flutter/core/routing/route_names.dart';
import 'package:biblia_ar_flutter/data/models/leccion.dart';
import 'package:biblia_ar_flutter/data/models/progreso.dart';
import 'package:biblia_ar_flutter/features/lesson/leccion_estado_helper.dart';
import 'package:biblia_ar_flutter/features/profiles/perfil_provider.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_loading_view.dart';
import 'package:biblia_ar_flutter/shared/widgets/lesson_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// kguanoluisa, Pantalla de progreso con LessonCard unificada y estado por leccion, variables v_lecciones y v_progresos, 2026-07-23
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<Leccion> vLecciones = [];
  List<Progreso> vProgresos = [];
  bool vCargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final repos = context.read<RepositoryProvider>();
    final perfil = context.read<PerfilProvider>().vPerfilActivo;
    if (perfil?.id == null) {
      return;
    }

    final lecciones = await repos.leccionRepository.obtenerTodas();
    final progresos = await repos.progresoRepository.obtenerPorPerfil(perfil!.id!);
    if (!mounted) return;
    setState(() {
      vLecciones = lecciones;
      vProgresos = progresos;
      vCargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi progreso')),
      body: vCargando
          ? const BiarLoadingView(vMensaje: 'Cargando progreso...')
          : ListView.separated(
              padding: const EdgeInsets.all(BiarSpacing.md),
              itemCount: vLecciones.length,
              separatorBuilder: (_, __) => const SizedBox(height: BiarSpacing.sm),
              itemBuilder: (context, index) {
                final leccion = vLecciones[index];
                final estado = LeccionEstadoHelper.resolverEstadoLeccion(
                  leccionId: leccion.id!,
                  progresos: vProgresos,
                );
                return LessonCard(
                  vTitulo: leccion.titulo,
                  vVersiculoReferencia: leccion.versiculoDisplay,
                  vIcono: BiarPictogramIcons.iconoPara(leccion.pictograma),
                  vEstadoLabel: estado,
                  onTap: () => Navigator.pushNamed(
                    context,
                    RouteNames.lesson,
                    arguments: leccion.id,
                  ),
                );
              },
            ),
    );
  }
}
