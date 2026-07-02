// Sal-B: crear estructura base de la estructura inicial del flujo de aprobación doctrinal - 02/07/2026
import 'package:flutter/material.dart';
import 'widgets/doctrinal_approval_dialog.dart';

class DoctrinalApprovalScreen extends StatefulWidget {
  const DoctrinalApprovalScreen({super.key});

  @override
  State<DoctrinalApprovalScreen> createState() => _DoctrinalApprovalScreenState();
}

class _DoctrinalApprovalScreenState extends State<DoctrinalApprovalScreen> {
  // Sal-B: implementar lógica principal de la estructura inicial del flujo de aprobación doctrinal - 02/07/2026
  bool _isApproved = false;

  // Sal-B: integrar la estructura inicial del flujo de aprobación doctrinal con el resto del módulo - 02/07/2026
  Future<void> _showApprovalDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const DoctrinalApprovalDialog(),
    );
    if (result != null) {
      setState(() {
        _isApproved = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aprobación Doctrinal'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Estado de Aprobación: ${_isApproved ? "Aprobado" : "Pendiente"}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showApprovalDialog,
              child: const Text('Evaluar Lección'),
            ),
          ],
        ),
      ),
    );
  }
}
