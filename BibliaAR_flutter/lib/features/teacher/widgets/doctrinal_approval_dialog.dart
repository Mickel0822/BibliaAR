// Sal-B: crear estructura base del cierre del flujo de aprobación doctrinal y la documentación técnica - 22/07/2026
// Sal-B: refactorizar código del flujo de aprobación doctrinal en revisión de código - 21/07/2026
// Sal-B: aplicar comentarios de revisión cruzada en el flujo de aprobación doctrinal en revisión de código - 20/07/2026
// Sal-B: optimizar rendimiento del flujo de aprobación doctrinal en revisión de código - 20/07/2026
// Sal-B: corregir bug detectado en pruebas del flujo de aprobación doctrinal en revisión de código - 20/07/2026
// Sal-B: ajustar UI/UX del flujo de aprobación doctrinal en revisión de código - 17/07/2026
// Sal-B: agregar validaciones y manejo de errores en el flujo de aprobación doctrinal en revisión de código - 17/07/2026
// Sal-B: integrar el flujo de aprobación doctrinal en revisión de código con el resto del módulo - 16/07/2026
// Sal-B: implementar lógica principal del flujo de aprobación doctrinal en revisión de código - 16/07/2026
// Sal-B: crear estructura base del flujo de aprobación doctrinal en revisión de código - 16/07/2026
// Sal-B: optimizar rendimiento del flujo de aprobación doctrinal - 15/07/2026
// Sal-B: corregir bug detectado en pruebas del flujo de aprobación doctrinal - 15/07/2026
// Sal-B: ajustar UI/UX del flujo de aprobación doctrinal - 14/07/2026
// Sal-B: agregar validaciones y manejo de errores en el flujo de aprobación doctrinal - 14/07/2026
// Sal-B: integrar el flujo de aprobación doctrinal con el resto del módulo - 13/07/2026
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
