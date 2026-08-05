import 'package:biblia_ar_flutter/core/constants/app_constants.dart';
import 'package:biblia_ar_flutter/core/routing/route_names.dart';
import 'package:biblia_ar_flutter/core/session/usage_timer_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// kguanoluisa, Listener global de alerta de 20 minutos de uso continuo con dialogo accesible, variable v_timerService, 2026-07-23
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
    final timer = context.read<UsageTimerService>();
    if (!timer.shouldShowAlert || !mounted) {
      return;
    }
    timer.markAlertShown();
    _mostrarDialogo();
  }

  Future<void> _mostrarDialogo() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tiempo de descanso'),
          content: Text(
            'Has usado la app durante ${AppConstants.usageAlertMinutes} minutos. '
            'Te recomendamos descansar la vista.',
          ),
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
              child: const Text('Salir'),
            ),
            FilledButton(
              onPressed: () {
                context.read<UsageTimerService>().reset();
                Navigator.pop(context);
              },
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
