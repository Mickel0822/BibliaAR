class MigrationV2 {
  static const int version = 2;

  static const String addCategoriaLecciones = '''
    ALTER TABLE lecciones ADD COLUMN categoria TEXT NOT NULL DEFAULT 'biblico'
  ''';

  static List<String> get statements => [addCategoriaLecciones];
}
