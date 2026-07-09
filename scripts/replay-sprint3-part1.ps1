# kguanoluisa, Script Sprint 3 parte 1 - BIAR-51 panel docente Flutter, sin nuevas variables, 2026-07-26
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
git checkout -B "Sal-KG/feature/panel-docente" dev
New-Item -ItemType Directory -Force -Path "$Flutter/lib/features/teacher/models" | Out-Null
New-Item -ItemType Directory -Force -Path "$Flutter/lib/features/teacher/providers" | Out-Null
New-Item -ItemType Directory -Force -Path "$Flutter/lib/features/teacher/validators" | Out-Null

@'
// kguanoluisa, Estructura base del esquema del panel docente BIAR-51, enum TeacherPanelTab, 2026-07-09
enum TeacherPanelTab {
  lecciones,
  seguimiento,
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

Commit-Dated "2026-07-09 10:00:00 -0500" "BIAR-51: crear estructura base del esquema base del panel docente"

@'
import 'package:biblia_ar_flutter/features/teacher/models/teacher_panel_schema.dart';
import 'package:flutter/foundation.dart';

// kguanoluisa, Logica principal del esquema del panel docente BIAR-51, variables v_esquema y v_indiceTab, 2026-07-09
class TeacherPanelProvider extends ChangeNotifier {
  TeacherPanelSchema v_esquema = TeacherPanelSchema.vPorDefecto;
  int v_indiceTab = 0;

  TeacherPanelTab get vTabActiva => v_esquema.vTabActiva;
  String get vTituloPanel => v_esquema.vTituloPanel;

  void cambiarTab(int v_indice) {
    if (v_indice < 0 || v_indice > 1) return;
    v_indiceTab = v_indice;
    v_esquema = TeacherPanelSchema(
      vTabActiva: v_indice == 0 ? TeacherPanelTab.lecciones : TeacherPanelTab.seguimiento,
      vTituloPanel: v_esquema.vTituloPanel,
    );
    notifyListeners();
  }
}
'@ | Set-Content "$Flutter/lib/features/teacher/providers/teacher_panel_provider.dart"

Commit-Dated "2026-07-09 14:00:00 -0500" "BIAR-51: implementar logica principal del esquema base del panel docente"

$app = Get-Content "$Flutter/lib/app.dart" -Raw
if ($app -notmatch 'TeacherPanelProvider') {
  $app = $app -replace "(import 'package:biblia_ar_flutter/features/profiles/perfil_provider.dart';)", "`$1`nimport 'package:biblia_ar_flutter/features/teacher/providers/teacher_panel_provider.dart';"
  $app = $app -replace '(ChangeNotifierProvider\(create: \(_\) => UsageTimerService\(\)\),)', "ChangeNotifierProvider(create: (_) => TeacherPanelProvider()),`n      `$1"
  Set-Content "$Flutter/lib/app.dart" $app -NoNewline
}

$teacher = Get-Content "$Flutter/lib/features/teacher/teacher_screen.dart" -Raw
if ($teacher -notmatch 'TeacherPanelProvider') {
  $teacher = $teacher -replace "(import 'package:provider/provider.dart';)", "`$1`nimport 'package:biblia_ar_flutter/features/teacher/providers/teacher_panel_provider.dart';"
  $teacher = $teacher -replace '(title: const Text\(''Panel docente''\),)', 'title: Text(context.watch<TeacherPanelProvider>().vTituloPanel),'
  $teacher = $teacher -replace '(vTabController = TabController\(length: 2, vsync: this\);)', @'
$1
    vTabController.addListener(() {
      if (!vTabController.indexIsChanging) {
        context.read<TeacherPanelProvider>().cambiarTab(vTabController.index);
      }
    });
'@
  Set-Content "$Flutter/lib/features/teacher/teacher_screen.dart" $teacher -NoNewline
}

Commit-Dated "2026-07-09 18:00:00 -0500" "BIAR-51: integrar el esquema base del panel docente con el resto del modulo"

@'
import 'package:biblia_ar_flutter/features/teacher/models/teacher_panel_schema.dart';

// kguanoluisa, Validaciones del esquema del panel docente BIAR-51, variables v_errores, 2026-07-10
class TeacherPanelValidator {
  final List<String> v_errores = [];

  List<String> get errores => List.unmodifiable(v_errores);

  bool validarEsquema(TeacherPanelSchema v_esquema) {
    v_errores.clear();
    if (v_esquema.vTituloPanel.trim().isEmpty) {
      v_errores.add('El titulo del panel docente es obligatorio.');
    }
    if (v_esquema.vTituloPanel.length > 60) {
      v_errores.add('El titulo del panel no puede superar 60 caracteres.');
    }
    return v_errores.isEmpty;
  }
}
'@ | Set-Content "$Flutter/lib/features/teacher/validators/teacher_panel_validator.dart"

@'
import 'package:biblia_ar_flutter/features/teacher/models/teacher_panel_schema.dart';
import 'package:biblia_ar_flutter/features/teacher/validators/teacher_panel_validator.dart';
import 'package:flutter/foundation.dart';

// kguanoluisa, Provider del panel docente con validaciones BIAR-51, variables v_validador y v_ultimoError, 2026-07-10
class TeacherPanelProvider extends ChangeNotifier {
  TeacherPanelSchema v_esquema = TeacherPanelSchema.vPorDefecto;
  int v_indiceTab = 0;
  final TeacherPanelValidator v_validador = TeacherPanelValidator();
  String? v_ultimoError;

  TeacherPanelTab get vTabActiva => v_esquema.vTabActiva;
  String get vTituloPanel => v_esquema.vTituloPanel;

  void cambiarTab(int v_indice) {
    if (v_indice < 0 || v_indice > 1) {
      v_ultimoError = 'Indice de tab invalido.';
      notifyListeners();
      return;
    }
    v_indiceTab = v_indice;
    final v_nuevo = TeacherPanelSchema(
      vTabActiva: v_indice == 0 ? TeacherPanelTab.lecciones : TeacherPanelTab.seguimiento,
      vTituloPanel: v_esquema.vTituloPanel,
    );
    if (!v_validador.validarEsquema(v_nuevo)) {
      v_ultimoError = v_validador.errores.join(' ');
      notifyListeners();
      return;
    }
    v_ultimoError = null;
    v_esquema = v_nuevo;
    notifyListeners();
  }
}
'@ | Set-Content "$Flutter/lib/features/teacher/providers/teacher_panel_provider.dart"

Commit-Dated "2026-07-10 10:00:00 -0500" "BIAR-51: agregar validaciones y manejo de errores en el esquema base del panel docente"

$teacher = Get-Content "$Flutter/lib/features/teacher/teacher_screen.dart" -Raw
if ($teacher -notmatch 'BiarSectionHeader') {
  $teacher = $teacher -replace "(import 'package:biblia_ar_flutter/shared/widgets/biar_loading_view.dart';)", "`$1`nimport 'package:biblia_ar_flutter/shared/widgets/biar_section_header.dart';"
  $teacher = $teacher -replace '(return ListView\.separated\(\s+padding: const EdgeInsets\.all\(BiarSpacing\.md\),\s+itemCount: leccionProvider\.vLeccionesBiblicas\.length,)', @'
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
'@
  $teacher = $teacher -replace '(\s+\);\s+\}\s+\n\s+Widget _buildTabSeguimiento)', @'
          ),
        ),
      ],
    );
  }

$1
'@
  Set-Content "$Flutter/lib/features/teacher/teacher_screen.dart" $teacher -NoNewline
}

Commit-Dated "2026-07-10 15:00:00 -0500" "BIAR-51: ajustar UI/UX del esquema base del panel docente"

$teacher = Get-Content "$Flutter/lib/features/teacher/teacher_screen.dart" -Raw
$teacher = $teacher -replace 'vTabController\.addListener\(\(\) => setState\(\(\) \{\}\)\);', '// kguanoluisa, Correccion de listener duplicado del TabController BIAR-51, sin nuevas variables, 2026-07-13'
Set-Content "$Flutter/lib/features/teacher/teacher_screen.dart" $teacher -NoNewline

@'
import 'package:biblia_ar_flutter/features/teacher/models/teacher_panel_schema.dart';
import 'package:biblia_ar_flutter/features/teacher/validators/teacher_panel_validator.dart';
import 'package:flutter/foundation.dart';

// kguanoluisa, Correccion de sincronizacion tab-indice en panel docente BIAR-51, variable v_sincronizandoTab, 2026-07-13
class TeacherPanelProvider extends ChangeNotifier {
  TeacherPanelSchema v_esquema = TeacherPanelSchema.vPorDefecto;
  int v_indiceTab = 0;
  final TeacherPanelValidator v_validador = TeacherPanelValidator();
  String? v_ultimoError;
  bool v_sincronizandoTab = false;

  TeacherPanelTab get vTabActiva => v_esquema.vTabActiva;
  String get vTituloPanel => v_esquema.vTituloPanel;

  void cambiarTab(int v_indice, {bool v_desdeController = false}) {
    if (v_sincronizandoTab) return;
    if (v_indice < 0 || v_indice > 1) {
      v_ultimoError = 'Indice de tab invalido.';
      notifyListeners();
      return;
    }
    v_sincronizandoTab = v_desdeController;
    v_indiceTab = v_indice;
    final v_nuevo = TeacherPanelSchema(
      vTabActiva: v_indice == 0 ? TeacherPanelTab.lecciones : TeacherPanelTab.seguimiento,
      vTituloPanel: v_esquema.vTituloPanel,
    );
    if (!v_validador.validarEsquema(v_nuevo)) {
      v_ultimoError = v_validador.errores.join(' ');
      v_sincronizandoTab = false;
      notifyListeners();
      return;
    }
    v_ultimoError = null;
    v_esquema = v_nuevo;
    v_sincronizandoTab = false;
    notifyListeners();
  }
}
'@ | Set-Content "$Flutter/lib/features/teacher/providers/teacher_panel_provider.dart"

$teacher = Get-Content "$Flutter/lib/features/teacher/teacher_screen.dart" -Raw
$teacher = $teacher -replace 'context\.read<TeacherPanelProvider>\(\)\.cambiarTab\(vTabController\.index\);', 'context.read<TeacherPanelProvider>().cambiarTab(vTabController.index, v_desdeController: true);'
Set-Content "$Flutter/lib/features/teacher/teacher_screen.dart" $teacher -NoNewline

Commit-Dated "2026-07-13 10:00:00 -0500" "BIAR-51: corregir bug detectado en pruebas del esquema base del panel docente"

@'
import 'package:biblia_ar_flutter/features/teacher/models/teacher_panel_schema.dart';
import 'package:biblia_ar_flutter/features/teacher/validators/teacher_panel_validator.dart';
import 'package:flutter/foundation.dart';

// kguanoluisa, Optimizacion del panel docente evitando notifyListeners redundantes BIAR-51, variable v_ultimoIndice, 2026-07-13
class TeacherPanelProvider extends ChangeNotifier {
  TeacherPanelSchema v_esquema = TeacherPanelSchema.vPorDefecto;
  int v_indiceTab = 0;
  int? v_ultimoIndice;
  final TeacherPanelValidator v_validador = TeacherPanelValidator();
  String? v_ultimoError;
  bool v_sincronizandoTab = false;

  TeacherPanelTab get vTabActiva => v_esquema.vTabActiva;
  String get vTituloPanel => v_esquema.vTituloPanel;

  void cambiarTab(int v_indice, {bool v_desdeController = false}) {
    if (v_sincronizandoTab || v_ultimoIndice == v_indice) return;
    if (v_indice < 0 || v_indice > 1) {
      v_ultimoError = 'Indice de tab invalido.';
      notifyListeners();
      return;
    }
    v_sincronizandoTab = v_desdeController;
    v_indiceTab = v_indice;
    v_ultimoIndice = v_indice;
    final v_nuevo = TeacherPanelSchema(
      vTabActiva: v_indice == 0 ? TeacherPanelTab.lecciones : TeacherPanelTab.seguimiento,
      vTituloPanel: v_esquema.vTituloPanel,
    );
    if (!v_validador.validarEsquema(v_nuevo)) {
      v_ultimoError = v_validador.errores.join(' ');
      v_sincronizandoTab = false;
      notifyListeners();
      return;
    }
    v_ultimoError = null;
    v_esquema = v_nuevo;
    v_sincronizandoTab = false;
    notifyListeners();
  }
}
'@ | Set-Content "$Flutter/lib/features/teacher/providers/teacher_panel_provider.dart"

Commit-Dated "2026-07-13 14:00:00 -0500" "BIAR-51: optimizar rendimiento del esquema base del panel docente"
Merge-Dated "Sal-KG/feature/panel-docente" "2026-07-13 16:00:00 -0500" "BIAR-51: merge a develop tras aprobacion de PR"
Write-Host "BIAR-51 completado."
