import 'package:biblia_ar_flutter/spike/persistencia_local/models/benchmark_result.dart';
import 'package:biblia_ar_flutter/spike/persistencia_local/persistencia_benchmark.dart';
import 'package:flutter/material.dart';

/// Pantalla de desarrollo para ejecutar y visualizar el spike de persistencia.
///
/// Accesible desde Ajustes; muestra tiempos de sqflite vs Hive
/// para apoyar la decisión técnica del Sprint 2.
class PersistenciaBenchmarkPage extends StatefulWidget {
  const PersistenciaBenchmarkPage({super.key});

  @override
  State<PersistenciaBenchmarkPage> createState() =>
      _PersistenciaBenchmarkPageState();
}

class _PersistenciaBenchmarkPageState extends State<PersistenciaBenchmarkPage> {
  bool _running = false;
  List<BenchmarkResult> _results = [];

  Future<void> _runBenchmark() async {
    setState(() {
      _running = true;
      _results = [];
    });

    try {
      final benchmark = PersistenciaBenchmark(recordCount: 50);
      final results = await benchmark.run();
      if (!mounted) return;
      setState(() => _results = results);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en benchmark: $error')),
      );
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spike: sqflite vs Hive'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Evaluación de almacenamiento local para historial de actividades.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _running ? null : _runBenchmark,
              icon: _running
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.speed),
              label: Text(_running ? 'Ejecutando...' : 'Ejecutar benchmark'),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _results.isEmpty
                  ? const Center(child: Text('Sin resultados aún'))
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final result = _results[index];
                        return ListTile(
                          title: Text('${result.storageName} · ${result.operation}'),
                          subtitle: Text('${result.durationMs} ms · ${result.recordCount} registros'),
                          trailing: Icon(
                            result.isSuccess ? Icons.check_circle : Icons.error,
                            color: result.isSuccess ? Colors.green : Colors.red,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
