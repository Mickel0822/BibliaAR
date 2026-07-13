// Sal-B: implementar lógica principal del flujo de aprobación doctrinal - 13/07/2026
// Sal-B: crear estructura base del flujo de aprobación doctrinal - 13/07/2026
// Sal-B: crear estructura base de la estructura inicial del flujo de aprobación doctrinal - 02/07/2026
import 'package:flutter/material.dart';

class DoctrinalApprovalDialog extends StatefulWidget {
  const DoctrinalApprovalDialog({super.key});

  @override
  State<DoctrinalApprovalDialog> createState() => _DoctrinalApprovalDialogState();
}

class _DoctrinalApprovalDialogState extends State<DoctrinalApprovalDialog> {
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Sal-B: optimizar rendimiento de la estructura inicial del flujo de aprobación doctrinal - 06/07/2026
    _commentController.dispose();
    super.dispose();
  }

  // Sal-B: implementar lógica principal de la estructura inicial del flujo de aprobación doctrinal - 02/07/2026
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Aprobación Doctrinal'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Desea evaluar doctrinalmente esta lección?'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(labelText: 'Observaciones (Obligatorio si rechaza)'),
              validator: (value) {
                // Sal-B: agregar validaciones y manejo de errores en la estructura inicial del flujo de aprobación doctrinal - 03/07/2026
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingrese una observación';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, false);
            }
          },
          child: const Text('Rechazar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: const Text('Aprobar'),
        ),
      ],
    );
  }
}

// Sal-B: aplicar comentarios de revisión cruzada en la estructura inicial del flujo de aprobación doctrinal - 06/07/2026
