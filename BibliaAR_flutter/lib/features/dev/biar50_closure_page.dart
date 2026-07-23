import 'package:biblia_ar_flutter/core/session/biar50_closure_report.dart';
import 'package:biblia_ar_flutter/core/session/biar50_closure_service.dart';
import 'package:biblia_ar_flutter/core/session/usage_timer_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Pantalla de cierre del ticket BIAR-50 (Extensión — paso a Listo).
///
/// Muestra criterios de aceptación y el estado Jira resultante
/// tras ejecutar el servicio de cierre.
class Biar50ClosurePage extends StatefulWidget {
  const Biar50ClosurePage({super.key});

  @override
  State<Biar50ClosurePage> createState() => _Biar50ClosurePageState();
}

class _Biar50ClosurePageState extends State<Biar50ClosurePage> {
  Biar50ClosureReport? _informe;
  String? _error;

  void _generarInforme() {
    setState(() {
      _error = null;
      _informe = null;
    });
    try {
      final timer = context.read<UsageTimerService>();
      final service = Biar50ClosureService(timer);
      setState(() => _informe = service.generarInformeCierre());
    } catch (error) {
      setState(() => _error = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cierre BIAR-50')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Evalúa criterios de aceptación y determina si el ticket '
              'puede pasar a la columna Listo en Jira.',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _generarInforme,
              icon: const Icon(Icons.task_alt),
              label: const Text('Generar informe de cierre'),
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            if (_informe != null) _buildInforme(_informe!),
          ],
        ),
      ),
    );
  }

  Widget _buildInforme(Biar50ClosureReport informe) {
    final esListo = informe.estado == Biar50JiraStatus.listo;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Chip(
            avatar: Icon(esListo ? Icons.check : Icons.hourglass_empty),
            label: Text(esListo ? 'Listo' : 'En progreso'),
            backgroundColor: esListo ? Colors.green.shade100 : Colors.orange.shade100,
          ),
          if (informe.observaciones != null) ...[
            const SizedBox(height: 8),
            Text(informe.observaciones!),
          ],
          const SizedBox(height: 12),
          Text(
            'Criterios: ${informe.criteriosCumplidos}/${informe.totalCriterios}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: informe.criterios.length,
              itemBuilder: (context, index) {
                final c = informe.criterios[index];
                return ListTile(
                  leading: Icon(
                    c.cumplido ? Icons.check_circle : Icons.cancel,
                    color: c.cumplido ? Colors.green : Colors.red,
                  ),
                  title: Text('${c.id}: ${c.descripcion}'),
                  subtitle: c.evidencia != null ? Text(c.evidencia!) : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
