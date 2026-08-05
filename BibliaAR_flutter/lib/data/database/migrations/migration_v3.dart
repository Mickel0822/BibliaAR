class MigrationV3 {
  static const int version = 3;

  static const String addHistoriaTexto = '''
    ALTER TABLE lecciones ADD COLUMN historia_texto TEXT NOT NULL DEFAULT ''
  ''';

  static const String addVersiculoReferencia = '''
    ALTER TABLE lecciones ADD COLUMN versiculo_referencia TEXT NOT NULL DEFAULT ''
  ''';

  static const String addVersiculoTexto = '''
    ALTER TABLE lecciones ADD COLUMN versiculo_texto TEXT NOT NULL DEFAULT ''
  ''';

  static const String addPictograma = '''
    ALTER TABLE lecciones ADD COLUMN pictograma TEXT NOT NULL DEFAULT 'historias'
  ''';

  static List<String> get statements => [
        addHistoriaTexto,
        addVersiculoReferencia,
        addVersiculoTexto,
        addPictograma,
      ];
}
