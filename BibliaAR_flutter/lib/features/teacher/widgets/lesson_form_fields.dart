import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/core/accessibility/biar_pictogram_icons.dart';
import 'package:biblia_ar_flutter/features/lesson/leccion_provider.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Campos del formulario de nueva leccion docente con validacion, variables v_tituloController, v_historiaController, v_versiculoRefController, v_versiculoTextoController, v_pictogramaSeleccionado, 2026-07-23
class LessonFormFields extends StatelessWidget {
  const LessonFormFields({
    super.key,
    required this.vTituloController,
    required this.vHistoriaController,
    required this.vVersiculoRefController,
    required this.vVersiculoTextoController,
    required this.vPictogramaSeleccionado,
    required this.onPictogramaChanged,
    this.vSoloLectura = false,
  });

  final TextEditingController vTituloController;
  final TextEditingController vHistoriaController;
  final TextEditingController vVersiculoRefController;
  final TextEditingController vVersiculoTextoController;
  final String vPictogramaSeleccionado;
  final ValueChanged<String> onPictogramaChanged;
  final bool vSoloLectura;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: vTituloController,
          readOnly: vSoloLectura,
          decoration: const InputDecoration(
            labelText: 'Título de la lección',
            border: OutlineInputBorder(),
          ),
          maxLength: LeccionDocenteValidacion.maxTitulo,
          validator: (value) {
            if ((value ?? '').trim().isEmpty) return 'Obligatorio';
            return null;
          },
        ),
        const SizedBox(height: BiarSpacing.md),
        TextFormField(
          controller: vHistoriaController,
          readOnly: vSoloLectura,
          decoration: const InputDecoration(
            labelText: 'Texto de la historia',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 6,
          maxLength: LeccionDocenteValidacion.maxHistoria,
          validator: (value) {
            if ((value ?? '').trim().isEmpty) return 'Obligatorio';
            return null;
          },
        ),
        const SizedBox(height: BiarSpacing.md),
        TextFormField(
          controller: vVersiculoRefController,
          readOnly: vSoloLectura,
          decoration: const InputDecoration(
            labelText: 'Referencia del versículo',
            hintText: 'Ej. Juan 3:16',
            border: OutlineInputBorder(),
          ),
          maxLength: LeccionDocenteValidacion.maxVersiculoReferencia,
          validator: (value) {
            if ((value ?? '').trim().isEmpty) return 'Obligatorio';
            return null;
          },
        ),
        const SizedBox(height: BiarSpacing.md),
        TextFormField(
          controller: vVersiculoTextoController,
          readOnly: vSoloLectura,
          decoration: const InputDecoration(
            labelText: 'Texto del versículo',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 4,
          maxLength: LeccionDocenteValidacion.maxVersiculoTexto,
          validator: (value) {
            if ((value ?? '').trim().isEmpty) return 'Obligatorio';
            return null;
          },
        ),
        const SizedBox(height: BiarSpacing.md),
        Text('Pictograma / ícono', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: BiarSpacing.sm),
        Wrap(
          spacing: BiarSpacing.sm,
          runSpacing: BiarSpacing.sm,
          children: BiarPictogramIcons.opcionesDocente.map((pictograma) {
            final seleccionado = vPictogramaSeleccionado == pictograma;
            return ChoiceChip(
              label: Text(BiarPictogramIcons.etiquetaPara(pictograma)),
              avatar: Icon(BiarPictogramIcons.iconoPara(pictograma), size: 18),
              selected: seleccionado,
              onSelected: vSoloLectura
                  ? null
                  : (_) => onPictogramaChanged(pictograma),
            );
          }).toList(),
        ),
      ],
    );
  }
}
