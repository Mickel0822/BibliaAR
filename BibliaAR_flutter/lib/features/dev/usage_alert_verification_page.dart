import 'package:biblia_ar_flutter/core/session/usage_alert_verification_result.dart';
import 'package:biblia_ar_flutter/core/session/usage_alert_verifier.dart';
import 'package:biblia_ar_flutter/core/session/usage_timer_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Pantalla de verificación manual/automática de la alerta BIAR-50.
///
/// Permite al equipo QA ejecutar el checklist sin esperar 20 minutos
/// y revisar cada comprobación con detalle.
class UsageAlertVerificationPage extends StatefulWidget {
  const UsageAlertVerificationPage({super.key});

  @override
  State<UsageAlertVerificationPage> createState() =>
      _UsageAlertVerificationPageState();
}

class _UsageAlertVerificationPageState extends State<UsageAlertVerificationPage> {
  UsageAlertVerificationResult? _resultado;
  String? _error;

  void _ejecutarVerificacion() {
    setState(() {
      _error = null;
      _resultado = null;
    });
    try {
      final timer = context.read<UsageTimerService>();
      final verifier = UsageAlertVerifier(timer);
      setState(() => _resultado = verifier.run());
    } catch (error) {
      setState(() => _error = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación alerta 20 min'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Checklist automático de la alerta de uso continuo (BIAR-50).',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _ejecutarVerificacion,
              icon: const Icon(Icons.fact_check),
              label: const Text('Ejecutar verificación'),
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            if (_resultado != null) _buildResultado(_resultado!),
          ],
        ),
      ),
    );
  }

  Widget _buildResultado(UsageAlertVerificationResult resultado) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resultado: ${resultado.aprobados}/${resultado.total} '
            '${resultado.todoAprobado ? '✓ Aprobado' : '✗ Con fallos'}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: resultado.items.length,
              itemBuilder: (context, index) {
                final item = resultado.items[index];
                return ListTile(
                  leading: Icon(
                    item.aprobado ? Icons.check_circle : Icons.cancel,
                    color: item.aprobado ? Colors.green : Colors.red,
                  ),
                  title: Text(item.descripcion),
                  subtitle: item.detalle != null ? Text(item.detalle!) : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
