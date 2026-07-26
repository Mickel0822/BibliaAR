import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/core/feedback/multimodal_feedback.dart';
import 'package:biblia_ar_flutter/features/lesson/leccion_provider.dart';
import 'package:biblia_ar_flutter/features/teacher/widgets/lesson_form_fields.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// kguanoluisa, Pantalla para crear leccion biblica por docente con validacion y guardado en SQLite, variables v_formKey y v_pictogramaSeleccionado, 2026-07-23
class NewLessonScreen extends StatefulWidget {
  const NewLessonScreen({super.key});

  @override
  State<NewLessonScreen> createState() => _NewLessonScreenState();
}

class _NewLessonScreenState extends State<NewLessonScreen> {
  final GlobalKey<FormState> vFormKey = GlobalKey<FormState>();
  final TextEditingController vTituloController = TextEditingController();
  final TextEditingController vHistoriaController = TextEditingController();
  final TextEditingController vVersiculoRefController = TextEditingController();
  final TextEditingController vVersiculoTextoController = TextEditingController();
  String vPictogramaSeleccionado = 'historias';
  bool vGuardando = false;

  @override
  void dispose() {
    vTituloController.dispose();
    vHistoriaController.dispose();
    vVersiculoRefController.dispose();
    vVersiculoTextoController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!(vFormKey.currentState?.validate() ?? false)) return;

    setState(() => vGuardando = true);
    final leccion = await context.read<LeccionProvider>().crearLeccionDocente(
          titulo: vTituloController.text,
          historiaTexto: vHistoriaController.text,
          versiculoReferencia: vVersiculoRefController.text,
          versiculoTexto: vVersiculoTextoController.text,
          pictograma: vPictogramaSeleccionado,
        );
    if (!mounted) return;
    setState(() => vGuardando = false);

    if (leccion == null) {
      final error = context.read<LeccionProvider>().vError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'No se pudo guardar la lección')),
      );
      return;
    }

    await MultimodalFeedback.success(context, mensaje: '¡Lección creada!');
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva lección')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(BiarSpacing.md),
        child: Form(
          key: vFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LessonFormFields(
                vTituloController: vTituloController,
                vHistoriaController: vHistoriaController,
                vVersiculoRefController: vVersiculoRefController,
                vVersiculoTextoController: vVersiculoTextoController,
                vPictogramaSeleccionado: vPictogramaSeleccionado,
                onPictogramaChanged: (valor) => setState(() => vPictogramaSeleccionado = valor),
              ),
              const SizedBox(height: BiarSpacing.lg),
              BiarButton(
                label: vGuardando ? 'Guardando...' : 'Guardar lección',
                icon: Icons.save,
                onPressed: vGuardando ? null : _guardar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
