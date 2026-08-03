import 'package:biblia_ar_flutter/core/feedback/multimodal_feedback.dart';
import 'package:biblia_ar_flutter/core/routing/route_names.dart';
import 'package:biblia_ar_flutter/data/models/fragmento_narrativo.dart';
import 'package:biblia_ar_flutter/features/egov/conadis/conadis_fragment_builder.dart';
import 'package:biblia_ar_flutter/features/egov/conadis/conadis_provider.dart';
import 'package:biblia_ar_flutter/features/egov/conadis/conadis_resultado_args.dart';
import 'package:biblia_ar_flutter/features/profiles/perfil_provider.dart';
import 'package:biblia_ar_flutter/shared/widgets/content_player_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// kguanoluisa, Pantalla de resultado CONADIS con ContentPlayerScaffold y dialogo guardar o no guardar, variables v_fragmentos y v_indiceFragmento, 2026-07-29
class ConadisResultadoScreen extends StatefulWidget {
  const ConadisResultadoScreen({super.key, required this.vArgs});

  final ConadisResultadoArgs vArgs;

  @override
  State<ConadisResultadoScreen> createState() => _ConadisResultadoScreenState();
}

class _ConadisResultadoScreenState extends State<ConadisResultadoScreen> {
  late List<FragmentoNarrativo> vFragmentos;
  int vIndiceFragmento = 0;
  bool vReproduciendo = false;

  @override
  void initState() {
    super.initState();
    vFragmentos = ConadisFragmentBuilder.construirFragmentosResultado(
      certificado: widget.vArgs.certificado,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarConfiguracion());
  }

  Future<void> _cargarConfiguracion() async {
    final perfil = context.read<PerfilProvider>().vPerfilActivo;
    if (perfil?.id != null) {
      await context.read<ConfiguracionProvider>().cargar(perfil!.id!);
    }
  }

  FragmentoNarrativo get _fragmentoActual => vFragmentos[vIndiceFragmento];

  bool get _esUltimoFragmento => vIndiceFragmento >= vFragmentos.length - 1;
  bool get _esPrimerFragmento => vIndiceFragmento == 0;

  void _fragmentoAnterior() {
    if (!_esPrimerFragmento) {
      setState(() => vIndiceFragmento--);
    }
  }

  void _fragmentoSiguiente() {
    if (!_esUltimoFragmento) {
      setState(() => vIndiceFragmento++);
    }
  }

  void _alternarReproduccion() {
    setState(() => vReproduciendo = !vReproduciendo);
  }

  Future<void> _mostrarDialogoGuardar() async {
    final guardar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('¿Guardar consulta?'),
          content: const Text(
            '¿Deseas guardar el resultado de esta consulta en este dispositivo? '
            'Si eliges no guardar, los datos no se almacenarán.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('No guardar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Guardar en este dispositivo'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (guardar == true) {
      final perfil = context.read<PerfilProvider>().vPerfilActivo;
      if (perfil?.id != null) {
        await context.read<ConadisProvider>().guardarConsulta(
              perfilId: perfil!.id!,
              certificado: widget.vArgs.certificado,
            );
      }
      if (!mounted) return;
      await MultimodalFeedback.success(context, mensaje: 'Consulta guardada en el dispositivo.');
    }

    if (!mounted) return;
    Navigator.of(context).popUntil(
      (route) => route.settings.name == RouteNames.conadis || route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final configuracion = context.watch<ConfiguracionProvider>().vConfiguracion;

    return ContentPlayerScaffold(
      vTitulo: 'Resultado CONADIS',
      vFragmento: _fragmentoActual,
      vIndiceActual: vIndiceFragmento,
      vTotalFragmentos: vFragmentos.length,
      vReproduciendo: vReproduciendo,
      vConfiguracion: configuracion,
      vEsUltimoFragmento: _esUltimoFragmento,
      vEsPrimerFragmento: _esPrimerFragmento,
      vTextoBotonFinal: 'Finalizar consulta',
      onAnterior: _fragmentoAnterior,
      onSiguiente: _fragmentoSiguiente,
      onAlternarReproduccion: _alternarReproduccion,
      onFinalizar: _mostrarDialogoGuardar,
    );
  }
}
