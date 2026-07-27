import 'dart:async';

import 'package:biblia_ar_flutter/core/constants/app_constants.dart';
import 'package:flutter/foundation.dart';

// kguanoluisa, Servicio de alerta por tiempo de uso continuo con reinicio tras pausa prolongada, variables v_elapsedSeconds y v_isPaused, 2026-07-23
class UsageTimerService extends ChangeNotifier {
  UsageTimerService();

  Timer? _timer;
  DateTime? _pausedAt;
  int vElapsedSeconds = 0;
  bool vIsPaused = false;
  bool vAlertShown = false;

  void start() {
    _timer?.cancel();
    vIsPaused = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!vIsPaused) {
        vElapsedSeconds++;
        notifyListeners();
      }
    });
  }

  void pause() {
    vIsPaused = true;
    _pausedAt = DateTime.now();
  }

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

  void reset() {
    vElapsedSeconds = 0;
    vAlertShown = false;
    vIsPaused = false;
    _pausedAt = null;
    notifyListeners();
  }

  bool get shouldShowAlert {
    return !vAlertShown &&
        vElapsedSeconds >= AppConstants.usageAlertMinutes * 60;
  }

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
