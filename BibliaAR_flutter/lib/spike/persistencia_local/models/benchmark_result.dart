/// Resultado de una operación individual dentro del benchmark de persistencia.
///
/// Spike técnico Sprint 2: comparación sqflite vs Hive para almacenamiento local.
/// Este modelo captura tiempos y conteos por operación (escritura/lectura).
class BenchmarkResult {
  const BenchmarkResult({
    required this.storageName,
    required this.operation,
    required this.durationMs,
    required this.recordCount,
    this.errorMessage,
  });

  /// Nombre del backend evaluado (`sqflite` o `hive`).
  final String storageName;

  /// Operación medida: `write`, `read` o `delete`.
  final String operation;

  /// Duración en milisegundos.
  final int durationMs;

  /// Cantidad de registros procesados en la operación.
  final int recordCount;

  /// Mensaje de error si la operación falló (null si fue exitosa).
  final String? errorMessage;

  bool get isSuccess => errorMessage == null;

  Map<String, dynamic> toMap() {
    return {
      'storage_name': storageName,
      'operation': operation,
      'duration_ms': durationMs,
      'record_count': recordCount,
      'error_message': errorMessage,
    };
  }
}
