/// Contrato común para los adaptadores de almacenamiento local del spike.
///
/// Permite ejecutar las mismas operaciones sobre sqflite y Hive
/// y comparar rendimiento de forma equitativa.
abstract class LocalStorageAdapter {
  /// Identificador legible del backend (`sqflite`, `hive`).
  String get name;

  /// Inicializa el almacenamiento (apertura de BD, caja Hive, etc.).
  Future<void> initialize();

  /// Inserta registros de prueba representando progreso de actividades.
  Future<void> writeBatch(int count);

  /// Lee todos los registros almacenados.
  Future<List<Map<String, dynamic>>> readAll();

  /// Elimina los datos de prueba generados por el benchmark.
  Future<void> clear();

  /// Libera recursos (cierre de conexiones).
  Future<void> dispose();
}
