import 'package:biblia_ar_flutter/core/accessibility/biar_pictogram_icons.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Barra de pictogramas contextuales sincronizados con el fragmento narrativo, variable v_pictogramas, 2026-07-23
class PictogramBar extends StatelessWidget {
  const PictogramBar({super.key, required this.vPictogramas});

  final List<String> vPictogramas;

  @override
  Widget build(BuildContext context) {
    if (vPictogramas.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: vPictogramas.map((pictograma) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  BiarPictogramIcons.iconoPara(pictograma),
                  size: 36,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 4),
                Text(
                  pictograma,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
