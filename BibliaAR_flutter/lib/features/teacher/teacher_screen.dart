import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/core/accessibility/biar_pictogram_icons.dart';
import 'package:biblia_ar_flutter/core/di/repository_provider.dart';
import 'package:biblia_ar_flutter/core/routing/route_names.dart';
import 'package:biblia_ar_flutter/data/models/leccion.dart';
import 'package:biblia_ar_flutter/data/models/perfil.dart';
import 'package:biblia_ar_flutter/data/models/resultado_actividad.dart';
import 'package:biblia_ar_flutter/data/models/tipo_usuario.dart';
import 'package:biblia_ar_flutter/features/lesson/leccion_provider.dart';
import 'package:biblia_ar_flutter/features/teacher/lesson_detail_screen.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_empty_view.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_loading_view.dart';
import 'package:biblia_ar_flutter/shared/widgets/lesson_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// kguanoluisa, Panel docente con tabs de lecciones y seguimiento de ninos, sin nuevas variables, 2026-07-23
class TeacherScreen extends StatefulWidget {
  const TeacherScreen({super.key});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> with SingleTickerProviderStateMixin {
  late final TabController vTabController;
  List<Perfil> vPerfilesNinos = [];
  Perfil? vPerfilSeleccionado;
  List<ResultadoActividad> vResultados = [];
  bool vCargandoSeguimiento = true;

  @override
  void initState() {
    super.initState();
    vTabController = TabController(length: 2, vsync: this);
    vTabController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeccionProvider>().cargarLeccionesBiblicas();
      _cargarPerfiles();
    });
  }

  @override
  void dispose() {
    vTabController.dispose();
    super.dispose();
  }

  Future<void> _cargarPerfiles() async {
    final repos = context.read<RepositoryProvider>();
    final perfiles = await repos.perfilRepository.obtenerPorTipo(TipoUsuario.nino.value);
    if (!mounted) return;
    setState(() {
      vPerfilesNinos = perfiles;
      vCargandoSeguimiento = false;
    });
  }

  Future<void> _seleccionarPerfil(Perfil perfil) async {
    final repos = context.read<RepositoryProvider>();
    final resultados = await repos.progresoRepository.obtenerResultadosPorPerfil(perfil.id!);
    if (!mounted) return;
    setState(() {
      vPerfilSeleccionado = perfil;
      vResultados = resultados;
    });
  }

  void _abrirDetalleLeccion(Leccion leccion) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LessonDetailScreen(vLeccion: leccion)),
    );
  }

  Map<int, List<ResultadoActividad>> _agruparPorActividad() {
    final mapa = <int, List<ResultadoActividad>>{};
    for (final resultado in vResultados) {
      mapa.putIfAbsent(resultado.actividadId, () => []).add(resultado);
    }
    return mapa;
  }

  Color _colorEstado(String resultado) {
    if (resultado == 'correcto') {
      return Colors.green.shade100;
    }
    return Colors.orange.shade100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel docente'),
        bottom: TabBar(
          controller: vTabController,
          tabs: const [
            Tab(text: 'Lecciones', icon: Icon(Icons.auto_stories)),
            Tab(text: 'Seguimiento', icon: Icon(Icons.people)),
          ],
        ),
      ),
      body: TabBarView(
        controller: vTabController,
        children: [
          _buildTabLecciones(),
          _buildTabSeguimiento(),
        ],
      ),
      floatingActionButton: vTabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, RouteNames.teacherNewLesson),
              icon: const Icon(Icons.add),
              label: const Text('Nueva lección'),
            )
          : null,
    );
  }

  Widget _buildTabLecciones() {
    final leccionProvider = context.watch<LeccionProvider>();

    if (leccionProvider.vCargando) {
      return const BiarLoadingView(vMensaje: 'Cargando lecciones...');
    }

    if (leccionProvider.vLeccionesBiblicas.isEmpty) {
      return BiarEmptyView(
        vMensaje: 'No hay lecciones registradas.',
        vAccionLabel: 'Crear lección',
        onAccion: () => Navigator.pushNamed(context, RouteNames.teacherNewLesson),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(BiarSpacing.md),
      itemCount: leccionProvider.vLeccionesBiblicas.length,
      separatorBuilder: (_, __) => const SizedBox(height: BiarSpacing.sm),
      itemBuilder: (context, index) {
        final leccion = leccionProvider.vLeccionesBiblicas[index];
        return LessonCard(
          vTitulo: leccion.titulo,
          vVersiculoReferencia: leccion.versiculoDisplay,
          vIcono: BiarPictogramIcons.iconoPara(leccion.pictograma),
          onTap: () => _abrirDetalleLeccion(leccion),
        );
      },
    );
  }

  Widget _buildTabSeguimiento() {
    if (vCargandoSeguimiento) {
      return const BiarLoadingView(vMensaje: 'Cargando perfiles...');
    }

    final ancho = MediaQuery.sizeOf(context).width;
    final esPantallaAncha = ancho >= 720;

    if (!esPantallaAncha) {
      return Column(
        children: [
          if (vPerfilSeleccionado != null)
            ListTile(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  vPerfilSeleccionado = null;
                  vResultados = [];
                }),
              ),
              title: Text(vPerfilSeleccionado!.nombre),
            ),
          Expanded(
            child: vPerfilSeleccionado == null
                ? _buildListaNinos()
                : _buildDetalleResultados(),
          ),
        ],
      );
    }

    return Row(
      children: [
        SizedBox(width: 280, child: _buildListaNinos()),
        const VerticalDivider(width: 1),
        Expanded(child: _buildDetalleResultados()),
      ],
    );
  }

  Widget _buildListaNinos() {
    if (vPerfilesNinos.isEmpty) {
      return const BiarEmptyView(
        vMensaje: 'No hay perfiles de niño registrados.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(BiarSpacing.md),
      itemCount: vPerfilesNinos.length,
      separatorBuilder: (_, __) => const SizedBox(height: BiarSpacing.sm),
      itemBuilder: (context, index) {
        final perfil = vPerfilesNinos[index];
        final seleccionado = vPerfilSeleccionado?.id == perfil.id;
        return ListTile(
          selected: seleccionado,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BiarRadius.md),
          ),
          leading: Icon(
            BiarModuleIcons.historias,
            color: seleccionado ? Theme.of(context).colorScheme.primary : null,
          ),
          title: Text(perfil.nombre),
          subtitle: const Text('Ver progreso y actividades'),
          onTap: () => _seleccionarPerfil(perfil),
        );
      },
    );
  }

  Widget _buildDetalleResultados() {
    if (vPerfilSeleccionado == null) {
      return const Center(
        child: Text('Selecciona un perfil de niño para ver resultados'),
      );
    }

    if (vResultados.isEmpty) {
      return BiarEmptyView(
        vMensaje: 'Sin intentos registrados para ${vPerfilSeleccionado!.nombre}.',
      );
    }

    final agrupados = _agruparPorActividad();

    return ListView.builder(
      padding: const EdgeInsets.all(BiarSpacing.md),
      itemCount: agrupados.length,
      itemBuilder: (context, index) {
        final actividadId = agrupados.keys.elementAt(index);
        final intentos = agrupados[actividadId]!;
        final ultimo = intentos.last;

        return Card(
          margin: const EdgeInsets.only(bottom: BiarSpacing.sm),
          child: ListTile(
            title: Text('Actividad #$actividadId'),
            subtitle: Text('${intentos.length} intento(s) registrados'),
            trailing: Chip(
              label: Text(ultimo.resultado),
              backgroundColor: _colorEstado(ultimo.resultado),
            ),
          ),
        );
      },
    );
  }
}
