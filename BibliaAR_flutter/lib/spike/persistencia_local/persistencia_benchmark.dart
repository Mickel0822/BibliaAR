import 'package:biblia_ar_flutter/spike/persistencia_local/models/benchmark_result.dart';
import 'package:biblia_ar_flutter/spike/persistencia_local/storage/hive_storage.dart';
import 'package:biblia_ar_flutter/spike/persistencia_local/storage/local_storage_adapter.dart';
import 'package:biblia_ar_flutter/spike/persistencia_local/storage/sqflite_storage.dart';

/// Orquestador del benchmark sqflite vs Hive.
///
/// Ejecuta operaciones equivalentes sobre ambos adaptadores y
/// devuelve métricas comparables para decidir la persistencia local del proyecto.
class PersistenciaBenchmark {
  PersistenciaBenchmark({
    List<LocalStorageAdapter>? adapters,
    this.recordCount = 100,
  }) : _adapters = adapters ??
            [
              SqfliteStorageAdapter(),
              HiveStorageAdapter(),
            ];

  final List<LocalStorageAdapter> _adapters;
  final int recordCount;

  /// Valida parámetros antes de ejecutar el benchmark.
  void validate() {
    if (recordCount <= 0) {
      throw ArgumentError.value(recordCount, 'recordCount', 'Debe ser mayor a cero');
    }
    if (_adapters.isEmpty) {
      throw StateError('Se requiere al menos un adaptador de almacenamiento');
    }
  }

  /// Ejecuta el ciclo completo: escritura, lectura y limpieza por adaptador.
  Future<List<BenchmarkResult>> run() async {
    validate();
    final results = <BenchmarkResult>[];

    for (final adapter in _adapters) {
      try {
        await adapter.initialize();

        results.add(await _measure(
          adapter: adapter,
          operation: 'write',
          action: () => adapter.writeBatch(recordCount),
        ));

        results.add(await _measure(
          adapter: adapter,
          operation: 'read',
          action: () => adapter.readAll(),
        ));

        results.add(await _measure(
          adapter: adapter,
          operation: 'delete',
          action: () => adapter.clear(),
        ));
      } catch (error) {
        results.add(BenchmarkResult(
          storageName: adapter.name,
          operation: 'error',
          durationMs: 0,
          recordCount: recordCount,
          errorMessage: error.toString(),
        ));
      } finally {
        await adapter.dispose();
      }
    }

    return results;
  }

  Future<BenchmarkResult> _measure({
    required LocalStorageAdapter adapter,
    required String operation,
    required Future<void> Function() action,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      await action();
      stopwatch.stop();
      return BenchmarkResult(
        storageName: adapter.name,
        operation: operation,
        durationMs: stopwatch.elapsedMilliseconds,
        recordCount: recordCount,
      );
    } catch (error) {
      stopwatch.stop();
      return BenchmarkResult(
        storageName: adapter.name,
        operation: operation,
        durationMs: stopwatch.elapsedMilliseconds,
        recordCount: recordCount,
        errorMessage: error.toString(),
      );
    }
  }
}
