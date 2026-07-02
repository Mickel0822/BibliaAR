// Sal-B: crear estructura base de la estructura inicial del flujo de aprobación doctrinal - 02/07/2026
import 'package:flutter/material.dart';

class DoctrinalApprovalDialog extends StatelessWidget {
  const DoctrinalApprovalDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      title: Text('Aprobación Doctrinal'),
      content: Text('¿Desea aprobar doctrinalmente esta lección?'),
    );
  }
}
