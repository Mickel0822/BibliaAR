import 'package:biblia_ar_flutter/core/accessibility/accessibility_sizes.dart';
import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/core/feedback/multimodal_feedback.dart';
import 'package:biblia_ar_flutter/features/egov/conadis/conadis_formato_validator.dart';
import 'package:biblia_ar_flutter/features/egov/conadis/conadis_provider.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// kguanoluisa, Pantalla de consulta CONADIS con manejo de errores de formato invalido via feedback multimodal, variables v_numeroController y v_formatoValido, 2026-07-28
class ConadisConsultaScreen extends StatefulWidget {
  const ConadisConsultaScreen({super.key});

  @override
  State<ConadisConsultaScreen> createState() => _ConadisConsultaScreenState();
}

class _ConadisConsultaScreenState extends State<ConadisConsultaScreen> {
  final TextEditingController vNumeroController = TextEditingController();
  bool vFormatoValido = false;

  @override
  void initState() {
    super.initState();
    vNumeroController.addListener(_validarEntrada);
  }

  void _validarEntrada() {
    final valido = context.read<ConadisProvider>().validarFormato(vNumeroController.text);
    if (valido != vFormatoValido) {
      setState(() => vFormatoValido = valido);
    }
  }

  Future<void> _consultar() async {
    final numero = vNumeroController.text;
    if (!ConadisFormatoValidator.esFormatoValido(numero)) {
      await MultimodalFeedback.error(
        context,
        mensaje: ConadisFormatoValidator.mensajeFormatoInvalido,
        pictogramas: const ['certificado', 'conadis'],
      );
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Formato válido: ${ConadisFormatoValidator.normalizar(numero)}')),
    );
  }

  @override
  void dispose() {
    vNumeroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificar certificado CONADIS')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(BiarSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Número de certificado', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: BiarSpacing.sm),
            TextField(
              controller: vNumeroController,
              decoration: InputDecoration(
                hintText: 'CON-2024-000001',
                helperText: 'Formato: CON-AAAA-NNNNNN',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(BiarRadius.sm)),
                suffixIcon: vFormatoValido
                    ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                    : null,
              ),
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(fontSize: AccessibilitySizes.minFontSize),
            ),
            const SizedBox(height: BiarSpacing.lg),
            BiarButton(label: 'Validar formato', icon: Icons.check, onPressed: _consultar),
          ],
        ),
      ),
    );
  }
}
