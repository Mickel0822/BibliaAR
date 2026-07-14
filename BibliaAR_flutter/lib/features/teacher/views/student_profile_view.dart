import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/core/accessibility/biar_pictogram_icons.dart';
import 'package:biblia_ar_flutter/data/models/perfil.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Logica principal de vista de perfil estudiante BIAR-52/53, variables v_perfil y v_onVolver, 2026-07-14
class StudentProfileView extends StatelessWidget {
  const StudentProfileView({
    super.key,
    required this.vPerfil,
    this.v_onVolver,
    this.v_mostrarVolver = false,
  });

  final Perfil vPerfil;
  final VoidCallback? v_onVolver;
  final bool v_mostrarVolver;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(BiarSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(BiarSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (v_mostrarVolver)
              IconButton(onPressed: v_onVolver, icon: const Icon(Icons.arrow_back)),
            Row(
              children: [
                Icon(BiarModuleIcons.historias, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: BiarSpacing.sm),
                Expanded(
                  child: Text(vPerfil.nombre, style: Theme.of(context).textTheme.titleLarge),
                ),
              ],
            ),
            const SizedBox(height: BiarSpacing.sm),
            Text('Progreso individual del estudiante', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
