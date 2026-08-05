import 'package:biblia_ar_flutter/shared/widgets/biar_button.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Widget de actividad tipo completar con opciones multiples, variable v_seleccion, 2026-07-23
class CompletarActividadWidget extends StatefulWidget {
  const CompletarActividadWidget({
    super.key,
    required this.payload,
    required this.onResultado,
  });

  final Map<String, dynamic> payload;
  final ValueChanged<bool> onResultado;

  @override
  State<CompletarActividadWidget> createState() => _CompletarActividadWidgetState();
}

class _CompletarActividadWidgetState extends State<CompletarActividadWidget> {
  int? vSeleccion;

  @override
  Widget build(BuildContext context) {
    final opciones = (widget.payload['opciones'] as List).cast<String>();
    final respuestaCorrecta = widget.payload['respuestaCorrecta'] as int;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.payload['titulo'] as String,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(widget.payload['pregunta'] as String),
        const SizedBox(height: 12),
        ...List.generate(opciones.length, (index) {
          return RadioListTile<int>(
            title: Text(opciones[index]),
            value: index,
            groupValue: vSeleccion,
            onChanged: (value) => setState(() => vSeleccion = value),
          );
        }),
        BiarButton(
          label: 'Comprobar',
          onPressed: vSeleccion == null
              ? null
              : () => widget.onResultado(vSeleccion == respuestaCorrecta),
        ),
      ],
    );
  }
}
