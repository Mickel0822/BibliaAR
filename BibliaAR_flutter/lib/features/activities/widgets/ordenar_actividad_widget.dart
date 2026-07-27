import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_button.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Actividad ordenar con badges numerados y resaltado animado del item movido, variable v_indiceResaltado, 2026-07-23
class OrdenarActividadWidget extends StatefulWidget {
  const OrdenarActividadWidget({
    super.key,
    required this.payload,
    required this.onResultado,
  });

  final Map<String, dynamic> payload;
  final ValueChanged<bool> onResultado;

  @override
  State<OrdenarActividadWidget> createState() => _OrdenarActividadWidgetState();
}

class _OrdenarActividadWidgetState extends State<OrdenarActividadWidget> {
  late List<String> vElementos;
  int? vIndiceResaltado;

  @override
  void initState() {
    super.initState();
    vElementos = (widget.payload['elementos'] as List).cast<String>();
  }

  void _mover(int index, int delta) {
    final nuevoIndex = index + delta;
    if (nuevoIndex < 0 || nuevoIndex >= vElementos.length) {
      return;
    }
    setState(() {
      final item = vElementos.removeAt(index);
      vElementos.insert(nuevoIndex, item);
      vIndiceResaltado = nuevoIndex;
    });
    Future.delayed(BiarDurations.fast, () {
      if (mounted) setState(() => vIndiceResaltado = null);
    });
  }

  void _comprobar() {
    final ordenCorrecto = (widget.payload['ordenCorrecto'] as List).cast<int>();
    final actual = <int>[];
    final originales = (widget.payload['elementos'] as List).cast<String>();
    for (final elemento in vElementos) {
      actual.add(originales.indexOf(elemento));
    }
    widget.onResultado(_listasIguales(actual, ordenCorrecto));
  }

  bool _listasIguales(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.payload['titulo'] as String,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: BiarSpacing.sm),
        Text(widget.payload['instruccion'] as String),
        const SizedBox(height: BiarSpacing.md),
        ...List.generate(vElementos.length, (index) {
          final resaltado = vIndiceResaltado == index;
          return AnimatedContainer(
            duration: BiarDurations.fast,
            curve: Curves.easeOut,
            margin: const EdgeInsets.only(bottom: BiarSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(BiarRadius.md),
              border: Border.all(
                color: resaltado
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.transparent,
                width: 2,
              ),
              color: resaltado
                  ? Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.4)
                  : null,
            ),
            child: Card(
              margin: EdgeInsets.zero,
              elevation: resaltado ? 4 : 1,
              child: ListTile(
                leading: CircleAvatar(
                  child: Text('${index + 1}'),
                ),
                title: Text(vElementos[index]),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_upward),
                      onPressed: () => _mover(index, -1),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward),
                      onPressed: () => _mover(index, 1),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        BiarButton(label: 'Comprobar orden', onPressed: _comprobar),
      ],
    );
  }
}
