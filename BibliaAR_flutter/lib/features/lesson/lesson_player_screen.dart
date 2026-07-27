import 'package:biblia_ar_flutter/core/feedback/multimodal_feedback.dart';
import 'package:biblia_ar_flutter/core/routing/route_names.dart';
import 'package:biblia_ar_flutter/features/ar_simulation/ar_preview_args.dart';
import 'package:biblia_ar_flutter/features/lesson/lesson_player_provider.dart';
import 'package:biblia_ar_flutter/features/profiles/perfil_provider.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_error_view.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_loading_view.dart';
import 'package:biblia_ar_flutter/shared/widgets/content_player_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// kguanoluisa, Reproductor de leccion con leccionId por ruta y soporte de contenido docente, variable v_leccionId, 2026-07-23
class LessonPlayerScreen extends StatefulWidget {
  const LessonPlayerScreen({super.key, this.vLeccionId = 1});

  final int vLeccionId;

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  Future<void> _cargar() async {
    if (!mounted) return;
    final perfil = context.read<PerfilProvider>().vPerfilActivo;
    if (perfil?.id != null) {
      await context.read<ConfiguracionProvider>().cargar(perfil!.id!);
    }
    if (!mounted) return;
    await context.read<LessonPlayerProvider>().cargarLeccion(
          leccionId: widget.vLeccionId,
          perfilId: perfil?.id,
        );
  }

  Future<void> _finalizarLeccion() async {
    final perfil = context.read<PerfilProvider>().vPerfilActivo;
    if (perfil?.id != null) {
      await context.read<LessonPlayerProvider>().completarLeccion(perfil!.id!);
    }
    if (!mounted) return;
    await MultimodalFeedback.success(context, mensaje: '¡Actividad lista!');
    if (!mounted) return;
    Navigator.pushNamed(context, RouteNames.activities);
  }

  void _abrirArPreview() {
    final fragmento = context.read<LessonPlayerProvider>().fragmentoActual;
    if (fragmento == null) return;
    Navigator.pushNamed(
      context,
      RouteNames.arPreview,
      arguments: ArPreviewArgs(
        vTitulo: fragmento.titulo,
        vOverlayAsset: fragmento.ilustracionAsset.isNotEmpty
            ? fragmento.ilustracionAsset
            : 'assets/illustrations/ar_overlay/samaritano.png',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LessonPlayerProvider>();
    final configuracion = context.watch<ConfiguracionProvider>().vConfiguracion;
    final fragmento = provider.fragmentoActual;

    if (provider.vCargando) {
      return const Scaffold(body: BiarLoadingView(vMensaje: 'Cargando lección...'));
    }
    if (provider.vError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lección')),
        body: BiarErrorView(vMensaje: provider.vError!, onReintentar: _cargar),
      );
    }
    if (fragmento == null) {
      return const Scaffold(
        body: BiarLoadingView(vMensaje: 'Preparando contenido...'),
      );
    }

    return ContentPlayerScaffold(
      vTitulo: provider.vLeccion?.titulo ?? 'Lección',
      vFragmento: fragmento,
      vIndiceActual: provider.vIndiceFragmento,
      vTotalFragmentos: provider.vFragmentos.length,
      vReproduciendo: provider.vReproduciendo,
      vConfiguracion: configuracion,
      vEsUltimoFragmento: provider.esUltimoFragmento,
      vEsPrimerFragmento: provider.esPrimerFragmento,
      onAnterior: provider.fragmentoAnterior,
      onSiguiente: provider.fragmentoSiguiente,
      onAlternarReproduccion: provider.alternarReproduccion,
      onFinalizar: _finalizarLeccion,
      onVerEnEspacio: _abrirArPreview,
    );
  }
}
