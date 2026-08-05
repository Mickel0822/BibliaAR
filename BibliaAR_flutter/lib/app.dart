import 'package:biblia_ar_flutter/core/accessibility/biar_theme.dart';
import 'package:biblia_ar_flutter/core/constants/app_constants.dart';
import 'package:biblia_ar_flutter/core/di/repository_provider.dart';
import 'package:biblia_ar_flutter/core/routing/app_router.dart';
import 'package:biblia_ar_flutter/core/routing/route_names.dart';
import 'package:biblia_ar_flutter/core/session/usage_timer_service.dart';
import 'package:biblia_ar_flutter/features/auth/auth_provider.dart';
import 'package:biblia_ar_flutter/features/activities/actividad_provider.dart';
import 'package:biblia_ar_flutter/features/lesson/leccion_provider.dart';
import 'package:biblia_ar_flutter/features/lesson/lesson_player_provider.dart';
import 'package:biblia_ar_flutter/features/profiles/perfil_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// kguanoluisa, Aplicacion BIAR con MultiProvider, tema accesible y repositorios SQLite, sin nuevas variables, 2026-07-23
class BiarApp extends StatelessWidget {
  const BiarApp({super.key, RepositoryProvider? repositoryProvider})
      : _repositoryProvider = repositoryProvider;

  final RepositoryProvider? _repositoryProvider;

  @override
  Widget build(BuildContext context) {
    final repos = _repositoryProvider ?? RepositoryProvider();

    return MultiProvider(
      providers: _buildProviders(repos),
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: BiarTheme.light(),
        initialRoute: RouteNames.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }

  List<SingleChildWidget> _buildProviders(RepositoryProvider repos) {
    return [
      Provider<RepositoryProvider>.value(value: repos),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(
        create: (_) => PerfilProvider(
          perfilRepository: repos.perfilRepository,
          configuracionRepository: repos.configuracionRepository,
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => ConfiguracionProvider(
          configuracionRepository: repos.configuracionRepository,
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => LeccionProvider(
          leccionRepository: repos.leccionRepository,
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => LessonPlayerProvider(
          leccionRepository: repos.leccionRepository,
          progresoRepository: repos.progresoRepository,
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => ActividadProvider(
          actividadRepository: repos.actividadRepository,
        ),
      ),
      ChangeNotifierProvider(create: (_) => UsageTimerService()),
    ];
  }
}
