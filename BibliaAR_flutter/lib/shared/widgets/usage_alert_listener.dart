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
  late final UsageTimerService _timerService;

  @override
  void initState() {
    super.initState();
    _timerService = context.read<UsageTimerService>();
    _timerService.addListener(_evaluarAlerta);
  }

  @override
  void dispose() {
    _timerService.removeListener(_evaluarAlerta);
    super.dispose();
  }

  void _evaluarAlerta() {
    if (!mounted) return;
    if (!_timerService.shouldShowAlert) {
      return;
    }
    // kguanoluisa, Evitar recursión y bloqueo difiriendo el cambio de estado de la alerta a la siguiente fase de renderizado, 2026-07-29
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_timerService.shouldShowAlert) {
        _timerService.markAlertShown();
        _mostrarDialogo();
      }
    });
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
                _timerService.reset();
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
                _timerService.reset();
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
