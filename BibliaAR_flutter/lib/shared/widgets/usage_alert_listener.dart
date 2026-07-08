import 'package:biblia_ar_flutter/core/constants/app_constants.dart';
import 'package:biblia_ar_flutter/core/routing/route_names.dart';
import 'package:biblia_ar_flutter/core/session/usage_timer_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Widget listener que muestra el diálogo de descanso tras 20 minutos (BIAR-50).
///
/// Se envuelve alrededor de pantallas principales (Home) para escuchar
/// cambios del [UsageTimerService] y disparar la alerta accesible.
class UsageAlertListener extends StatefulWidget {
  const UsageAlertListener({super.key, required this.child});

  final Widget child;

  @override
  State<UsageAlertListener> createState() => _UsageAlertListenerState();
}

class _UsageAlertListenerState extends State<UsageAlertListener> {
  @override
  void initState() {
    super.initState();
    context.read<UsageTimerService>().addListener(_evaluarAlerta);
  }

  @override
  void dispose() {
    context.read<UsageTimerService>().removeListener(_evaluarAlerta);
    super.dispose();
  }

  void _evaluarAlerta() {
    if (!mounted) return;
    final timer = context.read<UsageTimerService>();
    if (!timer.shouldShowAlert) {
      return;
    }
    timer.markAlertShown();
    _mostrarDialogo();
  }

  Future<void> _mostrarDialogo() async {
    if (!mounted) return;
    try {
      await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.visibility_outlined, size: 40),
          title: const Text('Tiempo de descanso'),
          content: Text(
            'Has usado la app durante ${AppConstants.usageAlertMinutes} minutos. '
            'Te recomendamos descansar la vista y parpadear con frecuencia.',
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteNames.login,
                  (_) => false,
                );
              },
              child: const Text('Salir de la app'),
            ),
            FilledButton.icon(
              onPressed: () {
                context.read<UsageTimerService>().reset();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Seguir aprendiendo'),
            ),
          ],
        );
      },
    );
    } catch (_) {
      // Evita fallo silencioso si el contexto dejó de estar montado.
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
