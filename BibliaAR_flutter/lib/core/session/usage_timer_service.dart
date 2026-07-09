import 'dart:async';

import 'package:biblia_ar_flutter/core/constants/app_constants.dart';
import 'package:flutter/foundation.dart';

/// Servicio de seguimiento de tiempo de uso continuo (BIAR-50).
///
/// Incrementa un contador cada segundo mientras la app está activa,
/// pausa en segundo plano y reinicia tras pausas prolongadas.
class UsageTimerService extends ChangeNotifier {
  UsageTimerService();

  Timer? _timer;
  DateTime? _pausedAt;

  /// Segundos transcurridos desde el inicio de la sesión activa.
  int vElapsedSeconds = 0;

  /// Indica si el contador está pausado (app en segundo plano).
  bool vIsPaused = false;

  /// Evita mostrar la alerta más de una vez por ciclo de uso.
  bool vAlertShown = false;

  /// Inicia el temporizador periódico de un segundo.
  void start() {
    if (_timer != null && _timer!.isActive) {
      return;
    }
    _timer?.cancel();
    vIsPaused = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (vIsPaused) return;
    vElapsedSeconds++;
    final threshold = AppConstants.usageAlertMinutes * 60;
    // Notifica solo cerca del umbral o cada 30 s para reducir rebuilds.
    if (vElapsedSeconds >= threshold - 30 ||
        vElapsedSeconds % 30 == 0 ||
        vElapsedSeconds >= threshold) {
      notifyListeners();
    }
  }

  /// Pausa el contador cuando la app pasa a segundo plano.
  void pause() {
    vIsPaused = true;
    _pausedAt = DateTime.now();
  }

  /// Reanuda el contador; reinicia si la pausa superó el umbral configurado.
  void resume() {
    if (_pausedAt != null) {
      final pauseDuration = DateTime.now().difference(_pausedAt!);
      if (pauseDuration.inMinutes >= AppConstants.usagePauseResetMinutes) {
        reset();
        return;
      }
    }
    vIsPaused = false;
    _pausedAt = null;
  }

  /// Reinicia contador y estado de alerta para un nuevo ciclo de uso.
  void reset() {
    if (vElapsedSeconds < 0) {
      throw StateError('El contador de uso no puede ser negativo');
    }
    vElapsedSeconds = 0;
    vAlertShown = false;
    vIsPaused = false;
    _pausedAt = null;
    notifyListeners();
  }

  /// Indica si debe mostrarse la alerta de 20 minutos.
  bool get shouldShowAlert {
    return !vAlertShown &&
        vElapsedSeconds >= AppConstants.usageAlertMinutes * 60;
  }

  /// Marca la alerta como mostrada para no repetirla en el mismo ciclo.
  void markAlertShown() {
    vAlertShown = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
