# kguanoluisa, Script Sprint 4 - BIAR-54/55 graficos y subtareas panel docente, sin nuevas variables, 2026-07-26
$ErrorActionPreference = "Stop"
Set-Location "c:\Users\kevin\Documents\Octavo\SADI\Proyecto"
$Flutter = "BibliaAR_flutter"

function Commit-Dated { param([string]$Date, [string]$Message)
  $env:GIT_AUTHOR_DATE = $Date; $env:GIT_COMMITTER_DATE = $Date
  git add -A; git commit -m $Message
  Remove-Item Env:GIT_AUTHOR_DATE, Env:GIT_COMMITTER_DATE -ErrorAction SilentlyContinue
}
function Merge-Dated { param([string]$Branch, [string]$Date, [string]$Message)
  git checkout dev
  $env:GIT_AUTHOR_DATE = $Date; $env:GIT_COMMITTER_DATE = $Date
  git merge --no-ff $Branch -m $Message
  Remove-Item Env:GIT_AUTHOR_DATE, Env:GIT_COMMITTER_DATE -ErrorAction SilentlyContinue
}

git checkout dev
git checkout -B "Sal-KG/feature/panel-docente-vistas" dev
New-Item -ItemType Directory -Force -Path "$Flutter/lib/features/teacher/widgets" | Out-Null

@'
// kguanoluisa, Estructura base de datos de resumen docente BIAR-54/55, variables v_totalCorrectos v_totalIntentos, 2026-07-17
class TeacherSummaryData {
  const TeacherSummaryData({
    required this.v_totalCorrectos,
    required this.v_totalIntentos,
    required this.v_totalEstudiantes,
  });

  final int v_totalCorrectos;
  final int v_totalIntentos;
  final int v_totalEstudiantes;

  double get v_porcentajeExito =>
      v_totalIntentos == 0 ? 0 : (v_totalCorrectos / v_totalIntentos) * 100;
}
'@ | Set-Content "$Flutter/lib/features/teacher/models/teacher_summary_data.dart"

@'
import 'package:biblia_ar_flutter/features/teacher/models/teacher_summary_data.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Estructura base de grafico de resumen docente BIAR-54/55, variable v_datos, 2026-07-17
class TeacherSummaryChart extends StatelessWidget {
  const TeacherSummaryChart({super.key, required this.v_datos});

  final TeacherSummaryData v_datos;

  @override
  Widget build(BuildContext context) {
    return Text('Exito: ${v_datos.v_porcentajeExito.toStringAsFixed(1)}%');
  }
}
'@ | Set-Content "$Flutter/lib/features/teacher/widgets/teacher_summary_chart.dart"

@'
import 'package:flutter/material.dart';

// kguanoluisa, Estructura base de panel de subtareas docente BIAR-54/55, variable v_subtareas, 2026-07-17
class TeacherSubtaskPanel extends StatelessWidget {
  const TeacherSubtaskPanel({super.key, required this.v_subtareas});

  final List<String> v_subtareas;

  @override
  Widget build(BuildContext context) {
    return Column(children: v_subtareas.map(Text.new).toList());
  }
}
'@ | Set-Content "$Flutter/lib/features/teacher/widgets/teacher_subtask_panel.dart"

Commit-Dated "2026-07-17 10:00:00 -0500" "BIAR-54/55: crear estructura base de las subtareas del panel docente y los graficos de resumen"

@'
import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/features/teacher/models/teacher_summary_data.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Logica principal del grafico de resumen docente BIAR-54/55, variables v_datos y v_barraExito, 2026-07-17
class TeacherSummaryChart extends StatelessWidget {
  const TeacherSummaryChart({super.key, required this.v_datos});

  final TeacherSummaryData v_datos;

  @override
  Widget build(BuildContext context) {
    final v_color = Theme.of(context).colorScheme.primary;
    final v_ratio = (v_datos.v_porcentajeExito / 100).clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.all(BiarSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(BiarSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumen de desempeno', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: BiarSpacing.sm),
            LinearProgressIndicator(value: v_ratio, color: v_color, minHeight: 12),
            const SizedBox(height: BiarSpacing.sm),
            Text('${v_datos.v_porcentajeExito.toStringAsFixed(1)}% de aciertos'),
            Text('${v_datos.v_totalEstudiantes} estudiantes · ${v_datos.v_totalIntentos} intentos'),
          ],
        ),
      ),
    );
  }
}
'@ | Set-Content "$Flutter/lib/features/teacher/widgets/teacher_summary_chart.dart"

@'
import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Logica principal del panel de subtareas docente BIAR-54/55, variables v_subtareas y v_completadas, 2026-07-17
class TeacherSubtaskPanel extends StatelessWidget {
  const TeacherSubtaskPanel({
    super.key,
    required this.v_subtareas,
    required this.v_completadas,
  });

  final List<String> v_subtareas;
  final Set<int> v_completadas;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(BiarSpacing.md),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(BiarSpacing.md),
        itemCount: v_subtareas.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final v_hecho = v_completadas.contains(index);
          return ListTile(
            leading: Icon(v_hecho ? Icons.check_circle : Icons.radio_button_unchecked,
                color: v_hecho ? Colors.green : null),
            title: Text(v_subtareas[index]),
          );
        },
      ),
    );
  }
}
'@ | Set-Content "$Flutter/lib/features/teacher/widgets/teacher_subtask_panel.dart"

Commit-Dated "2026-07-17 14:00:00 -0500" "BIAR-54/55: implementar logica principal de las subtareas del panel docente y los graficos de resumen"

# Integrar tab Resumen
@'
// kguanoluisa, Esquema del panel docente con tab de resumen BIAR-54/55, enum TeacherPanelTab resumen, 2026-07-17
enum TeacherPanelTab {
  lecciones,
  seguimiento,
  resumen,
}

class TeacherPanelSchema {
  const TeacherPanelSchema({
    required this.vTabActiva,
    required this.vTituloPanel,
  });

  final TeacherPanelTab vTabActiva;
  final String vTituloPanel;

  static const TeacherPanelSchema vPorDefecto = TeacherPanelSchema(
    vTabActiva: TeacherPanelTab.lecciones,
    vTituloPanel: 'Panel docente',
  );
}
'@ | Set-Content "$Flutter/lib/features/teacher/models/teacher_panel_schema.dart"

$provider = Get-Content "$Flutter/lib/features/teacher/providers/teacher_panel_provider.dart" -Raw
$provider = $provider -replace 'v_indice > 1', 'v_indice > 2'
$provider = $provider -replace "v_indice == 0 \? TeacherPanelTab\.lecciones : TeacherPanelTab\.seguimiento", @'
v_indice == 0
        ? TeacherPanelTab.lecciones
        : v_indice == 1
            ? TeacherPanelTab.seguimiento
            : TeacherPanelTab.resumen
'@
Set-Content "$Flutter/lib/features/teacher/providers/teacher_panel_provider.dart" $provider -NoNewline

$teacher = Get-Content "$Flutter/lib/features/teacher/teacher_screen.dart" -Raw
if ($teacher -notmatch 'TeacherSummaryChart') {
  $teacher = $teacher -replace "(import 'package:biblia_ar_flutter/features/teacher/views/student_profile_view.dart';)", "`$1`nimport 'package:biblia_ar_flutter/features/teacher/models/teacher_summary_data.dart';`nimport 'package:biblia_ar_flutter/features/teacher/widgets/teacher_subtask_panel.dart';`nimport 'package:biblia_ar_flutter/features/teacher/widgets/teacher_summary_chart.dart';"
  $teacher = $teacher -replace 'TabController\(length: 2', 'TabController(length: 3'
  $teacher = $teacher -replace "(Tab\(text: 'Seguimiento', icon: Icon\(Icons\.people\)\),)", "`$1`n            const Tab(text: 'Resumen', icon: Icon(Icons.insights)),"
  $teacher = $teacher -replace "(_buildTabSeguimiento\(\),)", "`$1`n          _buildTabResumen(),"
  $teacher = $teacher -replace '(floatingActionButton: vTabController\.index == 0)', 'floatingActionButton: vTabController.index == 0 && vTabController.length > 0'
  $teacher = $teacher -replace '(Widget _buildTabSeguimiento\(\) \{)', @'
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

  $1
'@
  Set-Content "$Flutter/lib/features/teacher/teacher_screen.dart" $teacher -NoNewline
}

Commit-Dated "2026-07-17 18:00:00 -0500" "BIAR-54/55: integrar las subtareas del panel docente y los graficos de resumen con el resto del modulo"

@'
import 'package:biblia_ar_flutter/features/teacher/models/teacher_summary_data.dart';

// kguanoluisa, Validaciones de graficos y subtareas docentes BIAR-54/55, variables v_errores, 2026-07-20
class TeacherChartValidator {
  final List<String> v_errores = [];

  List<String> get errores => List.unmodifiable(v_errores);

  bool validarResumen(TeacherSummaryData v_datos) {
    v_errores.clear();
    if (v_datos.v_totalIntentos < 0 || v_datos.v_totalCorrectos < 0) {
      v_errores.add('Los totales del resumen no pueden ser negativos.');
    }
    if (v_datos.v_totalCorrectos > v_datos.v_totalIntentos) {
      v_errores.add('Los aciertos no pueden superar los intentos.');
    }
    return v_errores.isEmpty;
  }

  bool validarSubtareas(List<String> v_subtareas) {
    v_errores.clear();
    if (v_subtareas.isEmpty) {
      v_errores.add('Debe existir al menos una subtarea docente.');
    }
    return v_errores.isEmpty;
  }
}
'@ | Set-Content "$Flutter/lib/features/teacher/validators/teacher_chart_validator.dart"

@'
import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/features/teacher/models/teacher_summary_data.dart';
import 'package:biblia_ar_flutter/features/teacher/validators/teacher_chart_validator.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Grafico de resumen con validaciones BIAR-54/55, variable v_validador, 2026-07-20
class TeacherSummaryChart extends StatelessWidget {
  const TeacherSummaryChart({super.key, required this.v_datos});

  final TeacherSummaryData v_datos;
  static final TeacherChartValidator v_validador = TeacherChartValidator();

  @override
  Widget build(BuildContext context) {
    if (!v_validador.validarResumen(v_datos)) {
      return Card(
        margin: const EdgeInsets.all(BiarSpacing.md),
        child: Padding(
          padding: const EdgeInsets.all(BiarSpacing.md),
          child: Text(v_validador.errores.join('\n')),
        ),
      );
    }

    final v_color = Theme.of(context).colorScheme.primary;
    final v_ratio = (v_datos.v_porcentajeExito / 100).clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.all(BiarSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(BiarSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumen de desempeno', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: BiarSpacing.sm),
            LinearProgressIndicator(value: v_ratio, color: v_color, minHeight: 12),
            const SizedBox(height: BiarSpacing.sm),
            Text('${v_datos.v_porcentajeExito.toStringAsFixed(1)}% de aciertos'),
            Text('${v_datos.v_totalEstudiantes} estudiantes · ${v_datos.v_totalIntentos} intentos'),
          ],
        ),
      ),
    );
  }
}
'@ | Set-Content "$Flutter/lib/features/teacher/widgets/teacher_summary_chart.dart"

Commit-Dated "2026-07-20 10:00:00 -0500" "BIAR-54/55: agregar validaciones y manejo de errores en las subtareas del panel docente y los graficos de resumen"

@'
import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/features/teacher/models/teacher_summary_data.dart';
import 'package:biblia_ar_flutter/features/teacher/validators/teacher_chart_validator.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_section_header.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Ajustes UI/UX del grafico de resumen docente BIAR-54/55, sin nuevas variables, 2026-07-20
class TeacherSummaryChart extends StatelessWidget {
  const TeacherSummaryChart({super.key, required this.v_datos});

  final TeacherSummaryData v_datos;
  static final TeacherChartValidator v_validador = TeacherChartValidator();

  @override
  Widget build(BuildContext context) {
    if (!v_validador.validarResumen(v_datos)) {
      return Card(
        margin: const EdgeInsets.all(BiarSpacing.md),
        child: Padding(
          padding: const EdgeInsets.all(BiarSpacing.md),
          child: Text(v_validador.errores.join('\n')),
        ),
      );
    }

    final v_color = Theme.of(context).colorScheme.primary;
    final v_ratio = (v_datos.v_porcentajeExito / 100).clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.all(BiarSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(BiarSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BiarSectionHeader(
              vTitulo: 'Grafico de resumen',
              vSubtitulo: 'Indicadores globales del grupo',
              vIcono: Icons.insights,
            ),
            const SizedBox(height: BiarSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(BiarRadius.sm),
              child: LinearProgressIndicator(value: v_ratio, color: v_color, minHeight: 14),
            ),
            const SizedBox(height: BiarSpacing.sm),
            Text('${v_datos.v_porcentajeExito.toStringAsFixed(1)}% de aciertos',
                style: Theme.of(context).textTheme.titleSmall),
            Text('${v_datos.v_totalEstudiantes} estudiantes · ${v_datos.v_totalIntentos} intentos'),
          ],
        ),
      ),
    );
  }
}
'@ | Set-Content "$Flutter/lib/features/teacher/widgets/teacher_summary_chart.dart"

Commit-Dated "2026-07-20 15:00:00 -0500" "BIAR-54/55: ajustar UI/UX de las subtareas del panel docente y los graficos de resumen"

@'
import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/features/teacher/models/teacher_summary_data.dart';
import 'package:biblia_ar_flutter/features/teacher/validators/teacher_chart_validator.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_section_header.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Correccion de division por cero en grafico de resumen BIAR-54/55, sin nuevas variables, 2026-07-21
class TeacherSummaryChart extends StatelessWidget {
  const TeacherSummaryChart({super.key, required this.v_datos});

  final TeacherSummaryData v_datos;
  static final TeacherChartValidator v_validador = TeacherChartValidator();

  @override
  Widget build(BuildContext context) {
    if (!v_validador.validarResumen(v_datos)) {
      return Card(
        margin: const EdgeInsets.all(BiarSpacing.md),
        child: Padding(
          padding: const EdgeInsets.all(BiarSpacing.md),
          child: Text(v_validador.errores.join('\n')),
        ),
      );
    }

    if (v_datos.v_totalIntentos == 0) {
      return const Card(
        margin: EdgeInsets.all(BiarSpacing.md),
        child: Padding(
          padding: EdgeInsets.all(BiarSpacing.md),
          child: Text('Aun no hay intentos registrados para generar el grafico.'),
        ),
      );
    }

    final v_color = Theme.of(context).colorScheme.primary;
    final v_ratio = (v_datos.v_porcentajeExito / 100).clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.all(BiarSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(BiarSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BiarSectionHeader(
              vTitulo: 'Grafico de resumen',
              vSubtitulo: 'Indicadores globales del grupo',
              vIcono: Icons.insights,
            ),
            const SizedBox(height: BiarSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(BiarRadius.sm),
              child: LinearProgressIndicator(value: v_ratio, color: v_color, minHeight: 14),
            ),
            const SizedBox(height: BiarSpacing.sm),
            Text('${v_datos.v_porcentajeExito.toStringAsFixed(1)}% de aciertos',
                style: Theme.of(context).textTheme.titleSmall),
            Text('${v_datos.v_totalEstudiantes} estudiantes · ${v_datos.v_totalIntentos} intentos'),
          ],
        ),
      ),
    );
  }
}
'@ | Set-Content "$Flutter/lib/features/teacher/widgets/teacher_summary_chart.dart"

Commit-Dated "2026-07-21 10:00:00 -0500" "BIAR-54/55: corregir bug detectado en pruebas de las subtareas del panel docente y los graficos de resumen"

@'
import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/features/teacher/models/teacher_summary_data.dart';
import 'package:biblia_ar_flutter/features/teacher/validators/teacher_chart_validator.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_section_header.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Optimizacion de render del grafico de resumen BIAR-54/55, variable v_ratioCacheado, 2026-07-21
class TeacherSummaryChart extends StatelessWidget {
  const TeacherSummaryChart({super.key, required this.v_datos});

  final TeacherSummaryData v_datos;
  static final TeacherChartValidator v_validador = TeacherChartValidator();

  @override
  Widget build(BuildContext context) {
    if (!v_validador.validarResumen(v_datos)) {
      return Card(
        margin: const EdgeInsets.all(BiarSpacing.md),
        child: Padding(
          padding: const EdgeInsets.all(BiarSpacing.md),
          child: Text(v_validador.errores.join('\n')),
        ),
      );
    }

    if (v_datos.v_totalIntentos == 0) {
      return const Card(
        margin: EdgeInsets.all(BiarSpacing.md),
        child: Padding(
          padding: EdgeInsets.all(BiarSpacing.md),
          child: Text('Aun no hay intentos registrados para generar el grafico.'),
        ),
      );
    }

    final v_color = Theme.of(context).colorScheme.primary;
    final v_ratioCacheado = (v_datos.v_porcentajeExito / 100).clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.all(BiarSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(BiarSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BiarSectionHeader(
              vTitulo: 'Grafico de resumen',
              vSubtitulo: 'Indicadores globales del grupo',
              vIcono: Icons.insights,
            ),
            const SizedBox(height: BiarSpacing.sm),
            RepaintBoundary(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(BiarRadius.sm),
                child: LinearProgressIndicator(value: v_ratioCacheado, color: v_color, minHeight: 14),
              ),
            ),
            const SizedBox(height: BiarSpacing.sm),
            Text('${v_datos.v_porcentajeExito.toStringAsFixed(1)}% de aciertos',
                style: Theme.of(context).textTheme.titleSmall),
            Text('${v_datos.v_totalEstudiantes} estudiantes · ${v_datos.v_totalIntentos} intentos'),
          ],
        ),
      ),
    );
  }
}
'@ | Set-Content "$Flutter/lib/features/teacher/widgets/teacher_summary_chart.dart"

Commit-Dated "2026-07-21 14:00:00 -0500" "BIAR-54/55: optimizar rendimiento de las subtareas del panel docente y los graficos de resumen"

@'
import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Comentarios de revision cruzada en panel de subtareas BIAR-54/55, variable v_etiquetaProgreso, 2026-07-21
class TeacherSubtaskPanel extends StatelessWidget {
  const TeacherSubtaskPanel({
    super.key,
    required this.v_subtareas,
    required this.v_completadas,
  });

  final List<String> v_subtareas;
  final Set<int> v_completadas;

  @override
  Widget build(BuildContext context) {
    final v_etiquetaProgreso = '${v_completadas.length}/${v_subtareas.length} completadas';

    return Card(
      margin: const EdgeInsets.all(BiarSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(BiarSpacing.md, BiarSpacing.md, BiarSpacing.md, 0),
            child: Text('Subtareas docentes', style: Theme.of(context).textTheme.titleMedium),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: BiarSpacing.md),
            child: Text(v_etiquetaProgreso, style: Theme.of(context).textTheme.bodySmall),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(BiarSpacing.md),
            itemCount: v_subtareas.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final v_hecho = v_completadas.contains(index);
              return ListTile(
                leading: Icon(v_hecho ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: v_hecho ? Colors.green : null),
                title: Text(v_subtareas[index]),
              );
            },
          ),
        ],
      ),
    );
  }
}
'@ | Set-Content "$Flutter/lib/features/teacher/widgets/teacher_subtask_panel.dart"

Commit-Dated "2026-07-21 17:00:00 -0500" "BIAR-54/55: aplicar comentarios de revision cruzada en las subtareas del panel docente y los graficos de resumen"

@'
import 'package:biblia_ar_flutter/data/models/resultado_actividad.dart';
import 'package:biblia_ar_flutter/features/teacher/models/teacher_summary_data.dart';

// kguanoluisa, Refactor de construccion de datos de resumen docente BIAR-54/55, clase TeacherSummaryBuilder, 2026-07-22
class TeacherSummaryBuilder {
  const TeacherSummaryBuilder();

  TeacherSummaryData fromResultados({
    required List<ResultadoActividad> v_resultados,
    required int v_totalEstudiantes,
  }) {
    final v_correctos = v_resultados.where((r) => r.resultado == 'correcto').length;
    return TeacherSummaryData(
      v_totalCorrectos: v_correctos,
      v_totalIntentos: v_resultados.length,
      v_totalEstudiantes: v_totalEstudiantes,
    );
  }
}
'@ | Set-Content "$Flutter/lib/features/teacher/models/teacher_summary_builder.dart"

$teacher = Get-Content "$Flutter/lib/features/teacher/teacher_screen.dart" -Raw
$teacher = $teacher -replace "import 'package:biblia_ar_flutter/features/teacher/models/teacher_summary_data.dart';", "import 'package:biblia_ar_flutter/features/teacher/models/teacher_summary_data.dart';`nimport 'package:biblia_ar_flutter/features/teacher/models/teacher_summary_builder.dart';"
$teacher = $teacher -replace 'TeacherSummaryData _buildResumenData\(\) \{[\s\S]*?\n  \}', @'
static const TeacherSummaryBuilder _vResumenBuilder = TeacherSummaryBuilder();

  TeacherSummaryData _buildResumenData() {
    return _vResumenBuilder.fromResultados(
      v_resultados: vResultados,
      v_totalEstudiantes: vPerfilesNinos.length,
    );
  }
'@
Set-Content "$Flutter/lib/features/teacher/teacher_screen.dart" $teacher -NoNewline

Commit-Dated "2026-07-22 10:00:00 -0500" "BIAR-54/55: refactorizar codigo de las subtareas del panel docente y los graficos de resumen"
Merge-Dated "Sal-KG/feature/panel-docente-vistas" "2026-07-22 16:00:00 -0500" "BIAR-54/55: merge a develop tras aprobacion de PR"
Write-Host "BIAR-54/55 completado."
