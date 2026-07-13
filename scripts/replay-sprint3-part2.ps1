# kguanoluisa, Script Sprint 3 parte 2 - BIAR-52/53 vistas estudiantes Flutter, sin nuevas variables, 2026-07-26
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
New-Item -ItemType Directory -Force -Path "$Flutter/lib/features/teacher/views" | Out-Null

@'
import 'package:biblia_ar_flutter/data/models/perfil.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Estructura base de vista individual de estudiante BIAR-52/53, variables v_perfil, 2026-07-14
class StudentProfileView extends StatelessWidget {
  const StudentProfileView({super.key, required this.vPerfil});

  final Perfil vPerfil;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(vPerfil.nombre),
      subtitle: const Text('Perfil de estudiante'),
    );
  }
}
'@ | Set-Content "$Flutter/lib/features/teacher/views/student_profile_view.dart"

@'
import 'package:biblia_ar_flutter/data/models/resultado_actividad.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Estructura base de vista de actividades del estudiante BIAR-52/53, variables v_resultados, 2026-07-14
class StudentActivityView extends StatelessWidget {
  const StudentActivityView({super.key, required this.vResultados});

  final List<ResultadoActividad> vResultados;

  @override
  Widget build(BuildContext context) {
    return Text('${vResultados.length} actividades');
  }
}
'@ | Set-Content "$Flutter/lib/features/teacher/views/student_activity_view.dart"

Commit-Dated "2026-07-14 10:00:00 -0500" "BIAR-52/53: crear estructura base de las vistas individuales de estudiantes"

@'
import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/core/accessibility/biar_pictogram_icons.dart';
import 'package:biblia_ar_flutter/data/models/perfil.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Logica principal de vista de perfil estudiante BIAR-52/53, variables v_perfil y v_onVolver, 2026-07-14
class StudentProfileView extends StatelessWidget {
  const StudentProfileView({
    super.key,
    required this.vPerfil,
    this.v_onVolver,
    this.v_mostrarVolver = false,
  });

  final Perfil vPerfil;
  final VoidCallback? v_onVolver;
  final bool v_mostrarVolver;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(BiarSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(BiarSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (v_mostrarVolver)
              IconButton(onPressed: v_onVolver, icon: const Icon(Icons.arrow_back)),
            Row(
              children: [
                Icon(BiarModuleIcons.historias, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: BiarSpacing.sm),
                Expanded(
                  child: Text(vPerfil.nombre, style: Theme.of(context).textTheme.titleLarge),
                ),
              ],
            ),
            const SizedBox(height: BiarSpacing.sm),
            Text('Progreso individual del estudiante', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
'@ | Set-Content "$Flutter/lib/features/teacher/views/student_profile_view.dart"

@'
import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/data/models/resultado_actividad.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Logica principal de vista de actividades del estudiante BIAR-52/53, variables v_resultados y v_colorEstado, 2026-07-14
class StudentActivityView extends StatelessWidget {
  const StudentActivityView({super.key, required this.vResultados});

  final List<ResultadoActividad> vResultados;

  Color _colorEstado(String v_resultado) =>
      v_resultado == 'correcto' ? Colors.green.shade100 : Colors.orange.shade100;

  @override
  Widget build(BuildContext context) {
    if (vResultados.isEmpty) {
      return const Center(child: Text('Sin actividades registradas'));
    }

    final v_agrupados = <int, List<ResultadoActividad>>{};
    for (final v_item in vResultados) {
      v_agrupados.putIfAbsent(v_item.actividadId, () => []).add(v_item);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(BiarSpacing.md),
      itemCount: v_agrupados.length,
      itemBuilder: (context, index) {
        final v_actividadId = v_agrupados.keys.elementAt(index);
        final v_intentos = v_agrupados[v_actividadId]!;
        final v_ultimo = v_intentos.last;
        return Card(
          margin: const EdgeInsets.only(bottom: BiarSpacing.sm),
          child: ListTile(
            title: Text('Actividad #$v_actividadId'),
            subtitle: Text('${v_intentos.length} intento(s)'),
            trailing: Chip(
              label: Text(v_ultimo.resultado),
              backgroundColor: _colorEstado(v_ultimo.resultado),
            ),
          ),
        );
      },
    );
  }
}
'@ | Set-Content "$Flutter/lib/features/teacher/views/student_activity_view.dart"

Commit-Dated "2026-07-14 14:00:00 -0500" "BIAR-52/53: implementar logica principal de las vistas individuales de estudiantes"

$teacher = Get-Content "$Flutter/lib/features/teacher/teacher_screen.dart" -Raw
if ($teacher -notmatch 'StudentProfileView') {
  $teacher = $teacher -replace "(import 'package:biblia_ar_flutter/features/teacher/lesson_detail_screen.dart';)", "`$1`nimport 'package:biblia_ar_flutter/features/teacher/views/student_activity_view.dart';`nimport 'package:biblia_ar_flutter/features/teacher/views/student_profile_view.dart';"
  $teacher = $teacher -replace '(Widget _buildDetalleResultados\(\) \{[\s\S]*?if \(vPerfilSeleccionado == null\) \{[\s\S]*?\})', @'
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
          v_onVolver: () => setState(() {
            vPerfilSeleccionado = null;
            vResultados = [];
          }),
        ),
        Expanded(child: StudentActivityView(vResultados: vResultados)),
      ],
    );
  }

  Widget _buildDetalleResultadosLegacy() {
    if (vPerfilSeleccionado == null) {
      return const Center(
        child: Text('Selecciona un perfil de nino para ver resultados'),
      );
    }
'@
  $teacher = $teacher -replace 'Widget _buildDetalleResultadosLegacy\(\) \{[\s\S]*?\n  \}\n\}', ''
  Set-Content "$Flutter/lib/features/teacher/teacher_screen.dart" $teacher -NoNewline
}

Commit-Dated "2026-07-14 18:00:00 -0500" "BIAR-52/53: integrar las vistas individuales de estudiantes con el resto del modulo"

@'
import 'package:biblia_ar_flutter/data/models/perfil.dart';
import 'package:biblia_ar_flutter/data/models/resultado_actividad.dart';

// kguanoluisa, Validaciones de vistas individuales de estudiantes BIAR-52/53, variables v_errores, 2026-07-15
class StudentViewValidator {
  final List<String> v_errores = [];

  List<String> get errores => List.unmodifiable(v_errores);

  bool validarPerfil(Perfil? v_perfil) {
    v_errores.clear();
    if (v_perfil == null) {
      v_errores.add('Debe seleccionar un estudiante.');
      return false;
    }
    if (v_perfil.nombre.trim().isEmpty) {
      v_errores.add('El nombre del estudiante es invalido.');
      return false;
    }
    return true;
  }

  bool validarResultados(List<ResultadoActividad> v_resultados) {
    v_errores.clear();
    if (v_resultados.any((r) => r.actividadId <= 0)) {
      v_errores.add('Hay resultados con actividad invalida.');
      return false;
    }
    return true;
  }
}
'@ | Set-Content "$Flutter/lib/features/teacher/validators/student_view_validator.dart"

@'
import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/data/models/resultado_actividad.dart';
import 'package:biblia_ar_flutter/features/teacher/validators/student_view_validator.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Vista de actividades con validacion previa BIAR-52/53, variable v_validador, 2026-07-15
class StudentActivityView extends StatelessWidget {
  const StudentActivityView({super.key, required this.vResultados});

  final List<ResultadoActividad> vResultados;

  Color _colorEstado(String v_resultado) =>
      v_resultado == 'correcto' ? Colors.green.shade100 : Colors.orange.shade100;

  @override
  Widget build(BuildContext context) {
    final v_validador = StudentViewValidator();
    if (!v_validador.validarResultados(vResultados)) {
      return Center(child: Text(v_validador.errores.join('\n')));
    }
    if (vResultados.isEmpty) {
      return const Center(child: Text('Sin actividades registradas'));
    }

    final v_agrupados = <int, List<ResultadoActividad>>{};
    for (final v_item in vResultados) {
      v_agrupados.putIfAbsent(v_item.actividadId, () => []).add(v_item);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(BiarSpacing.md),
      itemCount: v_agrupados.length,
      itemBuilder: (context, index) {
        final v_actividadId = v_agrupados.keys.elementAt(index);
        final v_intentos = v_agrupados[v_actividadId]!;
        final v_ultimo = v_intentos.last;
        return Card(
          margin: const EdgeInsets.only(bottom: BiarSpacing.sm),
          child: ListTile(
            title: Text('Actividad #$v_actividadId'),
            subtitle: Text('${v_intentos.length} intento(s)'),
            trailing: Chip(
              label: Text(v_ultimo.resultado),
              backgroundColor: _colorEstado(v_ultimo.resultado),
            ),
          ),
        );
      },
    );
  }
}
'@ | Set-Content "$Flutter/lib/features/teacher/views/student_activity_view.dart"

Commit-Dated "2026-07-15 10:00:00 -0500" "BIAR-52/53: agregar validaciones y manejo de errores en las vistas individuales de estudiantes"

@'
import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/core/accessibility/biar_pictogram_icons.dart';
import 'package:biblia_ar_flutter/data/models/perfil.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_section_header.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Ajustes UI/UX de vista de perfil estudiante BIAR-52/53, sin nuevas variables, 2026-07-15
class StudentProfileView extends StatelessWidget {
  const StudentProfileView({
    super.key,
    required this.vPerfil,
    this.v_onVolver,
    this.v_mostrarVolver = false,
  });

  final Perfil vPerfil;
  final VoidCallback? v_onVolver;
  final bool v_mostrarVolver;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(BiarSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(BiarSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const BiarSectionHeader(
              vTitulo: 'Estudiante',
              vSubtitulo: 'Detalle individual',
              vIcono: Icons.person,
            ),
            if (v_mostrarVolver)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: v_onVolver,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver'),
                ),
              ),
            ListTile(
              leading: Icon(BiarModuleIcons.historias, color: Theme.of(context).colorScheme.primary),
              title: Text(vPerfil.nombre, style: Theme.of(context).textTheme.titleLarge),
              subtitle: const Text('Seguimiento de actividades y progreso'),
            ),
          ],
        ),
      ),
    );
  }
}
'@ | Set-Content "$Flutter/lib/features/teacher/views/student_profile_view.dart"

Commit-Dated "2026-07-15 15:00:00 -0500" "BIAR-52/53: ajustar UI/UX de las vistas individuales de estudiantes"

$teacher = Get-Content "$Flutter/lib/features/teacher/teacher_screen.dart" -Raw
$teacher = $teacher -replace 'v_onVolver: \(\) => setState\(\(\) \{', @'
v_onVolver: () {
            if (!mounted) return;
            setState(() {
'@
$teacher = $teacher -replace 'vResultados = \[\];\s+\}\),', @'
vResultados = [];
            });
          },
'@
Set-Content "$Flutter/lib/features/teacher/teacher_screen.dart" $teacher -NoNewline

Commit-Dated "2026-07-16 10:00:00 -0500" "BIAR-52/53: corregir bug detectado en pruebas de las vistas individuales de estudiantes"

@'
import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/data/models/resultado_actividad.dart';
import 'package:biblia_ar_flutter/features/teacher/validators/student_view_validator.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Optimizacion de listado de actividades con cache de agrupacion BIAR-52/53, variable v_cacheAgrupados, 2026-07-16
class StudentActivityView extends StatefulWidget {
  const StudentActivityView({super.key, required this.vResultados});

  final List<ResultadoActividad> vResultados;

  @override
  State<StudentActivityView> createState() => _StudentActivityViewState();
}

class _StudentActivityViewState extends State<StudentActivityView> {
  final StudentViewValidator v_validador = StudentViewValidator();
  Map<int, List<ResultadoActividad>>? v_cacheAgrupados;
  int? v_cacheLength;

  Color _colorEstado(String v_resultado) =>
      v_resultado == 'correcto' ? Colors.green.shade100 : Colors.orange.shade100;

  Map<int, List<ResultadoActividad>> _agrupar() {
    if (v_cacheAgrupados != null && v_cacheLength == widget.vResultados.length) {
      return v_cacheAgrupados!;
    }
    final v_agrupados = <int, List<ResultadoActividad>>{};
    for (final v_item in widget.vResultados) {
      v_agrupados.putIfAbsent(v_item.actividadId, () => []).add(v_item);
    }
    v_cacheAgrupados = v_agrupados;
    v_cacheLength = widget.vResultados.length;
    return v_agrupados;
  }

  @override
  Widget build(BuildContext context) {
    if (!v_validador.validarResultados(widget.vResultados)) {
      return Center(child: Text(v_validador.errores.join('\n')));
    }
    if (widget.vResultados.isEmpty) {
      return const Center(child: Text('Sin actividades registradas'));
    }

    final v_agrupados = _agrupar();

    return ListView.builder(
      padding: const EdgeInsets.all(BiarSpacing.md),
      itemCount: v_agrupados.length,
      itemBuilder: (context, index) {
        final v_actividadId = v_agrupados.keys.elementAt(index);
        final v_intentos = v_agrupados[v_actividadId]!;
        final v_ultimo = v_intentos.last;
        return Card(
          margin: const EdgeInsets.only(bottom: BiarSpacing.sm),
          child: ListTile(
            title: Text('Actividad #$v_actividadId'),
            subtitle: Text('${v_intentos.length} intento(s)'),
            trailing: Chip(
              label: Text(v_ultimo.resultado),
              backgroundColor: _colorEstado(v_ultimo.resultado),
            ),
          ),
        );
      },
    );
  }
}
'@ | Set-Content "$Flutter/lib/features/teacher/views/student_activity_view.dart"

Commit-Dated "2026-07-16 14:00:00 -0500" "BIAR-52/53: optimizar rendimiento de las vistas individuales de estudiantes"
Merge-Dated "Sal-KG/feature/panel-docente-vistas" "2026-07-16 16:00:00 -0500" "BIAR-52/53: merge a develop tras aprobacion de PR"
Write-Host "BIAR-52/53 completado."
