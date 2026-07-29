import 'package:biblia_ar_flutter/core/accessibility/accessibility_sizes.dart';
import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/core/accessibility/biar_pictogram_icons.dart';
import 'package:biblia_ar_flutter/core/feedback/multimodal_feedback.dart';
import 'package:biblia_ar_flutter/core/routing/route_names.dart';
import 'package:biblia_ar_flutter/data/models/fragmento_narrativo.dart';
import 'package:biblia_ar_flutter/features/egov/conadis/conadis_assets_loader.dart';
import 'package:biblia_ar_flutter/features/egov/conadis/conadis_formato_validator.dart';
import 'package:biblia_ar_flutter/features/egov/conadis/conadis_provider.dart';
import 'package:biblia_ar_flutter/features/egov/conadis/conadis_resultado_args.dart';
import 'package:biblia_ar_flutter/features/profiles/perfil_provider.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_button.dart';
import 'package:biblia_ar_flutter/shared/widgets/floating_lse_player.dart';
import 'package:biblia_ar_flutter/shared/widgets/pictogram_bar.dart';
import 'package:biblia_ar_flutter/shared/widgets/subtitle_overlay.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// kguanoluisa, Pantalla de consulta CONADIS simplificada sin modo ni aviso de simulacion, variables v_numeroController y v_fragmentoAyuda, 2026-07-29
class ConadisConsultaScreen extends StatefulWidget {
  const ConadisConsultaScreen({super.key});

  @override
  State<ConadisConsultaScreen> createState() => _ConadisConsultaScreenState();
}

class _ConadisConsultaScreenState extends State<ConadisConsultaScreen> {
  final TextEditingController vNumeroController = TextEditingController();
  FragmentoNarrativo? vFragmentoAyuda;
  bool vFormatoValido = false;

  @override
  void initState() {
    super.initState();
    vNumeroController.addListener(_validarEntrada);
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  Future<void> _inicializar() async {
    final perfil = context.mounted ? context.read<PerfilProvider>().vPerfilActivo : null;
    if (perfil?.id != null) {
      await context.read<ConfiguracionProvider>().cargar(perfil!.id!);
    }
    final fragmentos = await ConadisAssetsLoader.cargarFragmentos(
      'assets/lessons/conadis_consulta/fragments.json',
    );
    if (mounted && fragmentos.isNotEmpty) {
      setState(() => vFragmentoAyuda = fragmentos.first);
    }
  }

  void _validarEntrada() {
    final valido = ConadisFormatoValidator.esFormatoValido(vNumeroController.text);
    if (valido != vFormatoValido) {
      setState(() => vFormatoValido = valido);
    }
  }

  Future<void> _consultar() async {
    final numero = vNumeroController.text;
    if (!ConadisFormatoValidator.esFormatoValido(numero)) {
      await MultimodalFeedback.error(
        context,
        mensaje: ConadisFormatoValidator.mensajeFormatoInvalido,
        pictogramas: const ['certificado', 'conadis'],
      );
      return;
    }

    final provider = context.read<ConadisProvider>();
    final resultado = await provider.consultar(numero);

    if (!mounted) return;

    if (resultado == null) {
      await MultimodalFeedback.info(
        context,
        mensaje:
            'No encontramos ese número en el registro. Verifica el número o inicia el trámite oficial.',
        pictogramas: const ['certificado', 'tramite'],
        onAccion: () => Navigator.pushNamed(context, RouteNames.orientacionCiudadana),
        etiquetaAccion: 'Ir a Orientación Ciudadana',
      );
      return;
    }

    Navigator.pushNamed(
      context,
      RouteNames.conadisResultado,
      arguments: ConadisResultadoArgs(certificado: resultado),
    );
  }

  @override
  void dispose() {
    vNumeroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final configuracion = context.watch<ConfiguracionProvider>().vConfiguracion;
    final consultando = context.watch<ConadisProvider>().vConsultando;
    final fragmento = vFragmentoAyuda;

    return Scaffold(
      appBar: AppBar(title: const Text('Verificar certificado CONADIS')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(BiarSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(BiarPictogramIcons.iconoPara('certificado'), size: 32),
                    const SizedBox(width: BiarSpacing.sm),
                    Expanded(
                      child: Text(
                        'Número de certificado',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                if (configuracion?.pictogramasActivos ?? true) ...[
                  const SizedBox(height: BiarSpacing.sm),
                  const PictogramBar(vPictogramas: ['certificado', 'conadis']),
                ],
                const SizedBox(height: BiarSpacing.sm),
                TextField(
                  controller: vNumeroController,
                  decoration: InputDecoration(
                    hintText: 'CON-2024-000001',
                    helperText: 'Formato: CON-AAAA-NNNNNN',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(BiarRadius.sm),
                    ),
                    suffixIcon: vFormatoValido
                        ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                        : null,
                  ),
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(fontSize: AccessibilitySizes.minFontSize),
                ),
                if (fragmento != null && (configuracion?.subtitulosActivos ?? true)) ...[
                  const SizedBox(height: BiarSpacing.sm),
                  SubtitleOverlay(vTexto: fragmento.textoSubtitulo),
                ],
                const SizedBox(height: BiarSpacing.lg),
                BiarButton(
                  label: consultando ? 'Consultando...' : 'Consultar',
                  icon: Icons.search,
                  onPressed: vFormatoValido && !consultando ? _consultar : null,
                ),
                const SizedBox(height: BiarSpacing.sm),
                BiarButton(
                  label: 'Orientación Ciudadana',
                  icon: Icons.help_outline,
                  expanded: false,
                  onPressed: () => Navigator.pushNamed(context, RouteNames.orientacionCiudadana),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          if (fragmento != null && (configuracion?.lseActivo ?? true))
            FloatingLsePlayer(
              vTitulo: fragmento.titulo,
              vDescripcion: fragmento.descripcion,
              vVideoAsset: fragmento.videoLseAsset,
            ),
        ],
      ),
    );
  }
}
