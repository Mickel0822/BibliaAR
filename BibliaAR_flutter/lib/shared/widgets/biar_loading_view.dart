import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Vista de carga consistente para estados async en pantallas, variable v_mensaje, 2026-07-23
class BiarLoadingView extends StatelessWidget {
  const BiarLoadingView({super.key, this.vMensaje = 'Cargando...'});

  final String vMensaje;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: BiarSpacing.md),
          Text(vMensaje, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
