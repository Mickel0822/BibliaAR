import 'package:biblia_ar_flutter/data/models/fragmento_narrativo.dart';
import 'package:biblia_ar_flutter/features/egov/conadis/conadis_assets_loader.dart';
import 'package:biblia_ar_flutter/features/profiles/perfil_provider.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_loading_view.dart';
import 'package:biblia_ar_flutter/shared/widgets/content_player_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// kguanoluisa, Pantalla de Orientacion Ciudadana CONADIS con pasos del tramite oficial accesible, variables v_fragmentos y v_indiceFragmento, 2026-07-29
class OrientacionCiudadanaScreen extends StatefulWidget {
  const OrientacionCiudadanaScreen({super.key});

  @override
  State<OrientacionCiudadanaScreen> createState() => _OrientacionCiudadanaScreenState();
}

class _OrientacionCiudadanaScreenState extends State<OrientacionCiudadanaScreen> {
  List<FragmentoNarrativo> vFragmentos = [];
  int vIndiceFragmento = 0;
  bool vReproduciendo = false;
  bool vCargando = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  Future<void> _cargar() async {
    final perfil = context.read<PerfilProvider>().vPerfilActivo;
    if (perfil?.id != null) {
      await context.read<ConfiguracionProvider>().cargar(perfil!.id!);
    }

    final fragmentos = await ConadisAssetsLoader.cargarFragmentos(
      'assets/lessons/orientacion_conadis/fragments.json',
    );

    if (mounted) {
      setState(() {
        vFragmentos = fragmentos;
        vCargando = false;
      });
    }
  }

  FragmentoNarrativo? get _fragmentoActual {
    if (vFragmentos.isEmpty) return null;
    return vFragmentos[vIndiceFragmento];
  }

  bool get _esUltimoFragmento => vIndiceFragmento >= vFragmentos.length - 1;
  bool get _esPrimerFragmento => vIndiceFragmento == 0;

  @override
  Widget build(BuildContext context) {
    if (vCargando) {
      return const Scaffold(
        body: BiarLoadingView(vMensaje: 'Cargando orientación...'),
      );
    }

    final fragmento = _fragmentoActual;
    if (fragmento == null) {
      return const Scaffold(
        body: BiarLoadingView(vMensaje: 'No hay contenido disponible'),
      );
    }

    final configuracion = context.watch<ConfiguracionProvider>().vConfiguracion;

    return ContentPlayerScaffold(
      vTitulo: 'Orientación Ciudadana',
      vFragmento: fragmento,
      vIndiceActual: vIndiceFragmento,
      vTotalFragmentos: vFragmentos.length,
      vReproduciendo: vReproduciendo,
      vConfiguracion: configuracion,
      vEsUltimoFragmento: _esUltimoFragmento,
      vEsPrimerFragmento: _esPrimerFragmento,
      vTextoBotonFinal: 'Volver',
      onAnterior: () {
        if (!_esPrimerFragmento) {
          setState(() => vIndiceFragmento--);
        }
      },
      onSiguiente: () {
        if (!_esUltimoFragmento) {
          setState(() => vIndiceFragmento++);
        }
      },
      onAlternarReproduccion: () {
        setState(() => vReproduciendo = !vReproduciendo);
      },
      onFinalizar: () => Navigator.of(context).pop(),
    );
  }
}
