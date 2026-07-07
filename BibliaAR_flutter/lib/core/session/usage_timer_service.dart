import 'package:flutter/foundation.dart';

/// Servicio de seguimiento de tiempo de uso continuo (BIAR-50).
///
/// Estructura base del contador que alertará tras 20 minutos de actividad.
/// La lógica de temporizador y pausas se implementa en commits posteriores.
class UsageTimerService extends ChangeNotifier {
  /// Segundos transcurridos desde el inicio de la sesión activa.
  int vElapsedSeconds = 0;

  /// Indica si el contador está pausado (app en segundo plano).
  bool vIsPaused = false;

  /// Evita mostrar la alerta más de una vez por ciclo de uso.
  bool vAlertShown = false;
}
