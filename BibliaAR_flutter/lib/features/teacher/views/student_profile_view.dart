import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/core/accessibility/biar_pictogram_icons.dart';
import 'package:biblia_ar_flutter/data/models/perfil.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_section_header.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Ajustes UI/UX de vista de perfil estudiante BIAR-52/53, sin nuevas variables, 2026-07-15
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
            const BiarSectionHeader(
              vTitulo: 'Estudiante',
              vSubtitulo: 'Detalle individual',
              vIcono: Icons.person,
            ),
            if (v_mostrarVolver)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: v_onVolver,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver'),
                ),
              ),
            ListTile(
              leading: Icon(BiarModuleIcons.historias, color: Theme.of(context).colorScheme.primary),
              title: Text(vPerfil.nombre, style: Theme.of(context).textTheme.titleLarge),
              subtitle: const Text('Seguimiento de actividades y progreso'),
            ),
          ],
        ),
      ),
    );
  }
}
