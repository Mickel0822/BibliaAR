// Sal-B: crear estructura base de la estructura inicial del flujo de aprobación doctrinal - 02/07/2026
import 'package:flutter/material.dart';

class DoctrinalApprovalDialog extends StatelessWidget {
  const DoctrinalApprovalDialog({super.key});

  // Sal-B: implementar lógica principal de la estructura inicial del flujo de aprobación doctrinal - 02/07/2026
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Aprobación Doctrinal'),
      content: const Text('¿Desea aprobar doctrinalmente esta lección?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Rechazar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Aprobar'),
        ),
      ],
    );
  }
}
