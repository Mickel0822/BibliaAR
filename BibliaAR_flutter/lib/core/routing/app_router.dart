import 'package:biblia_ar_flutter/core/routing/route_names.dart';
import 'package:biblia_ar_flutter/core/routing/route_transitions.dart';
import 'package:biblia_ar_flutter/features/activities/activities_hub_screen.dart';
import 'package:biblia_ar_flutter/features/ar_simulation/ar_preview_args.dart';
import 'package:biblia_ar_flutter/features/ar_simulation/ar_preview_screen.dart';
import 'package:biblia_ar_flutter/features/auth/login_screen.dart';
import 'package:biblia_ar_flutter/features/egov/conadis/conadis_consulta_screen.dart';
import 'package:biblia_ar_flutter/features/egov/conadis/conadis_resultado_args.dart';
import 'package:biblia_ar_flutter/features/egov/conadis/conadis_resultado_screen.dart';
import 'package:biblia_ar_flutter/features/egov/conadis/orientacion_ciudadana_screen.dart';
import 'package:biblia_ar_flutter/features/home/home_screen.dart';
import 'package:biblia_ar_flutter/features/lesson/lesson_player_screen.dart';
import 'package:biblia_ar_flutter/features/progress/progress_screen.dart';
import 'package:biblia_ar_flutter/features/settings/settings_screen.dart';
import 'package:biblia_ar_flutter/features/splash/splash_screen.dart';
import 'package:biblia_ar_flutter/features/teacher/new_lesson_screen.dart';
import 'package:biblia_ar_flutter/features/teacher/teacher_screen.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Enrutador central con rutas del modulo CONADIS eGovernment, sin nuevas variables, 2026-07-29
class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return RouteTransitions.fadeSlide(const SplashScreen(), settings);
      case RouteNames.login:
        return RouteTransitions.fadeSlide(const LoginScreen(), settings);
      case RouteNames.profiles:
      case RouteNames.createProfile:
        return RouteTransitions.fadeSlide(const HomeScreen(), settings);
      case RouteNames.home:
        return RouteTransitions.fadeSlide(const HomeScreen(), settings);
      case RouteNames.lesson:
        final leccionId = settings.arguments as int? ?? 1;
        return RouteTransitions.fadeSlide(
          LessonPlayerScreen(vLeccionId: leccionId),
          settings,
        );
      case RouteNames.arPreview:
        final args = settings.arguments as ArPreviewArgs?;
        return RouteTransitions.fadeSlide(
          ArPreviewScreen(vArgs: args ?? const ArPreviewArgs(vTitulo: 'Vista AR', vOverlayAsset: '')),
          settings,
        );
      case RouteNames.conadis:
        return RouteTransitions.fadeSlide(const ConadisConsultaScreen(), settings);
      case RouteNames.conadisResultado:
        final args = settings.arguments as ConadisResultadoArgs?;
        return RouteTransitions.fadeSlide(
          ConadisResultadoScreen(vArgs: args!),
          settings,
        );
      case RouteNames.orientacionCiudadana:
        return RouteTransitions.fadeSlide(const OrientacionCiudadanaScreen(), settings);
      case RouteNames.activities:
        return RouteTransitions.fadeSlide(const ActivitiesHubScreen(), settings);
      case RouteNames.settings:
        return RouteTransitions.fadeSlide(const SettingsScreen(), settings);
      case RouteNames.progress:
        return RouteTransitions.fadeSlide(const ProgressScreen(), settings);
      case RouteNames.teacher:
        return RouteTransitions.fadeSlide(const TeacherScreen(), settings);
      case RouteNames.teacherNewLesson:
        return RouteTransitions.fadeSlide(const NewLessonScreen(), settings);
      default:
        return RouteTransitions.fadeSlide(const SplashScreen(), settings);
    }
  }
}
