import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/data/models/leccion.dart';
import 'package:biblia_ar_flutter/features/teacher/widgets/lesson_form_fields.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Pantalla de detalle de leccion en solo lectura para el docente, sin nuevas variables, 2026-07-23
class LessonDetailScreen extends StatefulWidget {
  const LessonDetailScreen({super.key, required this.vLeccion});

  final Leccion vLeccion;

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  late final TextEditingController vTituloController;
  late final TextEditingController vHistoriaController;
  late final TextEditingController vVersiculoRefController;
  late final TextEditingController vVersiculoTextoController;
  late String vPictogramaSeleccionado;

  @override
  void initState() {
    super.initState();
    final leccion = widget.vLeccion;
    vTituloController = TextEditingController(text: leccion.titulo);
    vHistoriaController = TextEditingController(
      text: leccion.esLeccionDocente
          ? leccion.historiaTexto
          : 'Lección con contenido multimedia empaquetado',
    );
    vVersiculoRefController = TextEditingController(text: leccion.versiculoDisplay);
    vVersiculoTextoController = TextEditingController(
      text: leccion.versiculoTexto.isNotEmpty
          ? leccion.versiculoTexto
          : leccion.referenciaBiblica,
    );
    vPictogramaSeleccionado = leccion.pictograma;
  }

  @override
  void dispose() {
    vTituloController.dispose();
    vHistoriaController.dispose();
    vVersiculoRefController.dispose();
    vVersiculoTextoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de lección')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(BiarSpacing.md),
        child: LessonFormFields(
          vTituloController: vTituloController,
          vHistoriaController: vHistoriaController,
          vVersiculoRefController: vVersiculoRefController,
          vVersiculoTextoController: vVersiculoTextoController,
          vPictogramaSeleccionado: vPictogramaSeleccionado,
          onPictogramaChanged: (_) {},
          vSoloLectura: true,
        ),
      ),
    );
  }
}
