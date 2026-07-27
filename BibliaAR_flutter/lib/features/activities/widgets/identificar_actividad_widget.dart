import 'package:biblia_ar_flutter/shared/widgets/biar_button.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Widget de actividad tipo identificar personaje u opcion visual, variable v_seleccionId, 2026-07-23
class IdentificarActividadWidget extends StatefulWidget {
  const IdentificarActividadWidget({
    super.key,
    required this.payload,
    required this.onResultado,
  });

  final Map<String, dynamic> payload;
  final ValueChanged<bool> onResultado;

  @override
  State<IdentificarActividadWidget> createState() =>
      _IdentificarActividadWidgetState();
}

class _IdentificarActividadWidgetState extends State<IdentificarActividadWidget> {
  String? vSeleccionId;

  @override
  Widget build(BuildContext context) {
    final opciones = (widget.payload['opciones'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    final respuestaCorrecta = widget.payload['respuestaCorrecta'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.payload['titulo'] as String,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(widget.payload['instruccion'] as String),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: opciones.map((opcion) {
            final id = opcion['id'] as String;
            final seleccionado = vSeleccionId == id;
            return ChoiceChip(
              label: Text(opcion['nombre'] as String),
              selected: seleccionado,
              onSelected: (_) => setState(() => vSeleccionId = id),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        BiarButton(
          label: 'Comprobar',
          onPressed: vSeleccionId == null
              ? null
              : () => widget.onResultado(vSeleccionId == respuestaCorrecta),
        ),
      ],
    );
  }
}
