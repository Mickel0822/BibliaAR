// Sal-B: crear estructura base de la estructura inicial del flujo de aprobación doctrinal - 02/07/2026
import 'package:flutter/material.dart';

class DoctrinalApprovalScreen extends StatelessWidget {
  const DoctrinalApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aprobación Doctrinal'),
      ),
      body: const Center(
        child: Text('Estructura base del flujo doctrinal'),
      ),
    );
  }
}
