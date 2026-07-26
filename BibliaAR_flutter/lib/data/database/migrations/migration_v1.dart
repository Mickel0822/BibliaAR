class MigrationV1 {
  static const int version = 1;

  static const String createPerfiles = '''
    CREATE TABLE perfiles (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL,
      tipo_usuario TEXT NOT NULL,
      avatar_path TEXT,
      creado_en TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      sync_status TEXT NOT NULL DEFAULT 'local'
    )
  ''';

  static const String createConfiguracion = '''
    CREATE TABLE configuracion (
      perfil_id INTEGER PRIMARY KEY,
      lse_activo INTEGER NOT NULL DEFAULT 1,
      subtitulos_activos INTEGER NOT NULL DEFAULT 1,
      audio_activo INTEGER NOT NULL DEFAULT 1,
      pictogramas_activos INTEGER NOT NULL DEFAULT 1,
      velocidad_audio REAL NOT NULL DEFAULT 1.0,
      volumen_audio REAL NOT NULL DEFAULT 1.0,
      updated_at TEXT NOT NULL,
      sync_status TEXT NOT NULL DEFAULT 'local',
      FOREIGN KEY (perfil_id) REFERENCES perfiles(id)
    )
  ''';

  static const String createLecciones = '''
    CREATE TABLE lecciones (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      titulo TEXT NOT NULL,
      referencia_biblica TEXT NOT NULL,
      contenido_multimedia_path TEXT NOT NULL,
      categoria TEXT NOT NULL DEFAULT 'biblico',
      orden INTEGER NOT NULL DEFAULT 0,
      historia_texto TEXT NOT NULL DEFAULT '',
      versiculo_referencia TEXT NOT NULL DEFAULT '',
      versiculo_texto TEXT NOT NULL DEFAULT '',
      pictograma TEXT NOT NULL DEFAULT 'historias',
      updated_at TEXT NOT NULL,
      sync_status TEXT NOT NULL DEFAULT 'local'
    )
  ''';

  static const String createProgreso = '''
    CREATE TABLE progreso (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      perfil_id INTEGER NOT NULL,
      leccion_id INTEGER NOT NULL,
      estado TEXT NOT NULL,
      fecha TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      sync_status TEXT NOT NULL DEFAULT 'local',
      UNIQUE(perfil_id, leccion_id),
      FOREIGN KEY (perfil_id) REFERENCES perfiles(id),
      FOREIGN KEY (leccion_id) REFERENCES lecciones(id)
    )
  ''';

  static const String createActividades = '''
    CREATE TABLE actividades (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      leccion_id INTEGER NOT NULL,
      tipo TEXT NOT NULL,
      payload_json TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      sync_status TEXT NOT NULL DEFAULT 'local',
      FOREIGN KEY (leccion_id) REFERENCES lecciones(id)
    )
  ''';

  static const String createResultados = '''
    CREATE TABLE resultados_actividad (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      perfil_id INTEGER NOT NULL,
      actividad_id INTEGER NOT NULL,
      resultado TEXT NOT NULL,
      intento_numero INTEGER NOT NULL,
      fecha TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      sync_status TEXT NOT NULL DEFAULT 'local',
      FOREIGN KEY (perfil_id) REFERENCES perfiles(id),
      FOREIGN KEY (actividad_id) REFERENCES actividades(id)
    )
  ''';

  static List<String> get statements => [
        createPerfiles,
        createConfiguracion,
        createLecciones,
        createProgreso,
        createActividades,
        createResultados,
      ];
}
