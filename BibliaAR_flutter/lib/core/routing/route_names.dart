class RouteNames {
  static const String splash = '/';
  static const String login = '/login';
  static const String profiles = '/profiles';
  static const String createProfile = '/profiles/create';
  static const String home = '/home';
  static const String lesson = '/lesson';
  static const String arPreview = '/ar-preview';
  static const String tramites = '/tramites';
  static const String conadis = '/conadis';
  static const String conadisResultado = '/conadis/resultado';

  static const String activities = '/activities';
  static const String activityDetail = '/activities/detail';
  static const String settings = '/settings';
  static const String progress = '/progress';
  static const String teacher = '/teacher';
  static const String teacherNewLesson = '/teacher/lesson/new';
  static const String doctrinalApproval = '/teacher/doctrinal-approval';
  /// Ruta del spike técnico sqflite vs Hive (Sprint 2).
  static const String persistenciaBenchmark = '/dev/persistencia-benchmark';
  /// Historial de actividades del perfil activo (BIAR-44).
  static const String historialActividades = '/profiles/historial';
  /// Panel de verificación QA de la alerta BIAR-50 (Sprint 4).
  static const String usageAlertVerification = '/dev/usage-alert-verification';
  /// Informe de cierre BIAR-50 y paso a columna Listo (Extensión).
  static const String biar50Closure = '/dev/biar50-closure';
}
