// kguanoluisa, Migracion v4 con tablas certificados_conadis y consultas_conadis_guardadas, sin nuevas variables, 2026-07-29
class MigrationV4 {
  static const int version = 4;

  static const String createCertificadosConadis = '''
    CREATE TABLE certificados_conadis (
      numero_certificado TEXT PRIMARY KEY,
      tipo_discapacidad TEXT NOT NULL,
      porcentaje INTEGER NOT NULL,
      nombre_titular TEXT
    )
  ''';

  static const String createConsultasConadisGuardadas = '''
    CREATE TABLE consultas_conadis_guardadas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      perfil_id INTEGER NOT NULL,
      numero_certificado TEXT NOT NULL,
      tipo_discapacidad TEXT NOT NULL,
      porcentaje INTEGER NOT NULL,
      consultado_en TEXT NOT NULL,
      FOREIGN KEY (perfil_id) REFERENCES perfiles(id)
    )
  ''';

  static List<String> get statements => [
        createCertificadosConadis,
        createConsultasConadisGuardadas,
      ];
}
