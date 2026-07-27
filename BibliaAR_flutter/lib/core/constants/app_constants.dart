/// Constantes globales de la aplicación BIAR.
class AppConstants {
  static const String appName = 'BIAR';
  static const String leccionBuenSamaritanoPath =
      'assets/lessons/buen_samaritano/fragments.json';
  static const String subtitulosBuenSamaritanoPath =
      'assets/lessons/buen_samaritano/subtitles.json';

  /// Minutos de uso continuo antes de mostrar la alerta de descanso (BIAR-50).
  static const int usageAlertMinutes = 20;

  /// Minutos en pausa tras los cuales se reinicia el contador de uso (BIAR-50).
  static const int usagePauseResetMinutes = 5;
}
