import 'package:biblia_ar_flutter/core/constants/app_constants.dart';
import 'package:biblia_ar_flutter/core/session/usage_alert_verification_result.dart';
import 'package:biblia_ar_flutter/core/session/usage_timer_service.dart';

/// Verificador automático de la alerta de uso continuo (BIAR-50).
///
/// Ejecuta comprobaciones sobre el [UsageTimerService] sin esperar
/// 20 minutos reales, usando simulación de estados para QA.
class UsageAlertVerifier {
  UsageAlertVerifier(this._timer);

  final UsageTimerService _timer;

  /// Ejecuta el checklist completo de verificación.
  UsageAlertVerificationResult run() {
    final items = <UsageAlertCheckItem>[
      _verificarUmbralConfigurado(),
      _verificarEstadoInicial(),
      _verificarSimulacionUmbral(),
      _verificarReinicioTrasReset(),
      _verificarMarcaAlertaMostrada(),
    ];

    return UsageAlertVerificationResult(
      items: items,
      fecha: DateTime.now(),
    );
  }

  UsageAlertCheckItem _verificarUmbralConfigurado() {
    final ok = AppConstants.usageAlertMinutes == 20;
    return UsageAlertCheckItem(
      id: 'umbral_config',
      descripcion: 'Umbral de alerta configurado a 20 minutos',
      aprobado: ok,
      detalle: ok ? null : 'Valor actual: ${AppConstants.usageAlertMinutes}',
    );
  }

  UsageAlertCheckItem _verificarEstadoInicial() {
    final ok = !_timer.shouldShowAlert && !_timer.vAlertShown;
    return UsageAlertCheckItem(
      id: 'estado_inicial',
      descripcion: 'Contador inicia sin alerta pendiente',
      aprobado: ok,
    );
  }

  UsageAlertCheckItem _verificarSimulacionUmbral() {
    final umbral = AppConstants.usageAlertMinutes * 60;
    _timer.vElapsedSeconds = umbral;
    final ok = _timer.shouldShowAlert;
    _timer.reset();
    return UsageAlertCheckItem(
      id: 'simulacion_umbral',
      descripcion: 'shouldShowAlert es true al alcanzar el umbral',
      aprobado: ok,
    );
  }

  UsageAlertCheckItem _verificarReinicioTrasReset() {
    _timer.vElapsedSeconds = AppConstants.usageAlertMinutes * 60;
    _timer.vAlertShown = true;
    _timer.reset();
    final ok = _timer.vElapsedSeconds == 0 && !_timer.vAlertShown;
    return UsageAlertCheckItem(
      id: 'reset',
      descripcion: 'reset() limpia contador y bandera de alerta',
      aprobado: ok,
    );
  }

  UsageAlertCheckItem _verificarMarcaAlertaMostrada() {
    _timer.vElapsedSeconds = AppConstants.usageAlertMinutes * 60;
    _timer.markAlertShown();
    final ok = _timer.vAlertShown && !_timer.shouldShowAlert;
    _timer.reset();
    return UsageAlertCheckItem(
      id: 'marca_alerta',
      descripcion: 'markAlertShown() evita alertas duplicadas',
      aprobado: ok,
    );
  }
}
