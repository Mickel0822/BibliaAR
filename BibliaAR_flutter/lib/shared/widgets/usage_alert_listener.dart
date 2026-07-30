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
  late final UsageTimerService _timerService;
  bool _dialogVisible = false;

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
    if (!mounted || _dialogVisible) return;
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
    if (!mounted || _dialogVisible) return;
    _dialogVisible = true;
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
                _timerService.reset();
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
                _timerService.reset();
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
    } finally {
      _dialogVisible = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
