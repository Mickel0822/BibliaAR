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
import 'package:biblia_ar_flutter/features/teacher/views/student_activity_view.dart';
import 'package:biblia_ar_flutter/features/teacher/views/student_profile_view.dart';
import 'package:biblia_ar_flutter/features/teacher/models/teacher_summary_data.dart';
import 'package:biblia_ar_flutter/features/teacher/widgets/teacher_subtask_panel.dart';
import 'package:biblia_ar_flutter/features/teacher/widgets/teacher_summary_chart.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_empty_view.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_loading_view.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_section_header.dart';
import 'package:biblia_ar_flutter/shared/widgets/lesson_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biblia_ar_flutter/features/teacher/providers/teacher_panel_provider.dart';

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
    vTabController = TabController(length: 3, vsync: this);
    vTabController.addListener(() {
      if (!vTabController.indexIsChanging) {
        context.read<TeacherPanelProvider>().cambiarTab(vTabController.index, v_desdeController: true);
      }
    });
    // kguanoluisa, Correccion de listener duplicado del TabController BIAR-51, sin nuevas variables, 2026-07-13
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
        title: Text(context.watch<TeacherPanelProvider>().vTituloPanel),
        bottom: TabBar(
          controller: vTabController,
          tabs: const [
            Tab(text: 'Lecciones', icon: Icon(Icons.auto_stories)),
            Tab(text: 'Seguimiento', icon: Icon(Icons.people)),
            const Tab(text: 'Resumen', icon: Icon(Icons.insights)),
          ],
        ),
      ),
      body: TabBarView(
        controller: vTabController,
        children: [
          _buildTabLecciones(),
          _buildTabSeguimiento(),
          _buildTabResumen(),
        ],
      ),
      floatingActionButton: vTabController.index == 0 && vTabController.length > 0
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(BiarSpacing.md, BiarSpacing.md, BiarSpacing.md, 0),
          child: BiarSectionHeader(
            vTitulo: 'Lecciones biblicas',
            vSubtitulo: 'Contenido disponible para tus estudiantes',
            vIcono: Icons.auto_stories,
          ),
        ),
        Expanded(
          child: ListView.separated(
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
          ),
        ),
      ],
    );
  }

  TeacherSummaryData _buildResumenData() {
    final v_correctos = vResultados.where((r) => r.resultado == 'correcto').length;
    return TeacherSummaryData(
      v_totalCorrectos: v_correctos,
      v_totalIntentos: vResultados.length,
      v_totalEstudiantes: vPerfilesNinos.length,
    );
  }

  // kguanoluisa, Integracion de resumen y subtareas en panel docente BIAR-54/55, sin nuevas variables, 2026-07-17
  Widget _buildTabResumen() {
    final v_datos = _buildResumenData();
    const v_subtareas = [
      'Revisar lecciones activas',
      'Verificar progreso de estudiantes',
      'Actualizar contenido LSE',
      'Exportar reporte semanal',
    ];
    return ListView(
      padding: const EdgeInsets.all(BiarSpacing.md),
      children: [
        TeacherSummaryChart(v_datos: v_datos),
        TeacherSubtaskPanel(
          v_subtareas: v_subtareas,
          v_completadas: const {0, 1},
        ),
      ],
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
            });
          },
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
        child: Text('Selecciona un perfil de nino para ver resultados'),
      );
    }

    // kguanoluisa, Integracion de vistas individuales de estudiantes BIAR-52/53, sin nuevas variables, 2026-07-14
    final v_ancho = MediaQuery.sizeOf(context).width;
    return Column(
      children: [
        StudentProfileView(
          vPerfil: vPerfilSeleccionado!,
          v_mostrarVolver: v_ancho < 720,
          v_onVolver: () {
            if (!mounted) return;
            setState(() {
            vPerfilSeleccionado = null;
            vResultados = [];
            });
          },
        ),
        Expanded(child: StudentActivityView(vResultados: vResultados)),
      ],
    );
  }
}
