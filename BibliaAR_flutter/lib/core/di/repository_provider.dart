import 'package:biblia_ar_flutter/data/database/app_database.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/actividad_repository.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/conadis_repository.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/configuracion_repository.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/leccion_repository.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/perfil_repository.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/progreso_repository.dart';
import 'package:biblia_ar_flutter/data/repositories/sqlite/sqlite_actividad_repository.dart';
import 'package:biblia_ar_flutter/data/repositories/sqlite/sqlite_conadis_repository.dart';
import 'package:biblia_ar_flutter/data/repositories/sqlite/sqlite_configuracion_repository.dart';
import 'package:biblia_ar_flutter/data/repositories/sqlite/sqlite_leccion_repository.dart';
import 'package:biblia_ar_flutter/data/repositories/sqlite/sqlite_perfil_repository.dart';
import 'package:biblia_ar_flutter/data/repositories/sqlite/sqlite_progreso_repository.dart';

// kguanoluisa, Contenedor de repositorios SQLite con repositorio CONADIS para consulta offline, variable v_database, 2026-07-29
class RepositoryProvider {
  RepositoryProvider({AppDatabase? database})
      : vDatabase = database ?? AppDatabase.instance {
    perfilRepository = SqlitePerfilRepository(vDatabase);
    configuracionRepository = SqliteConfiguracionRepository(vDatabase);
    leccionRepository = SqliteLeccionRepository(vDatabase);
    progresoRepository = SqliteProgresoRepository(vDatabase);
    actividadRepository = SqliteActividadRepository(vDatabase);
    conadisRepository = SqliteConadisRepository(vDatabase);
  }

  final AppDatabase vDatabase;
  late final PerfilRepository perfilRepository;
  late final ConfiguracionRepository configuracionRepository;
  late final LeccionRepository leccionRepository;
  late final ProgresoRepository progresoRepository;
  late final ActividadRepository actividadRepository;
  late final ConadisRepository conadisRepository;
}
