// Sal-B: agregar validaciones y manejo de errores en el cierre del flujo de aprobación doctrinal y la documentación técnica - 23/07/2026
// Sal-B: integrar el cierre del flujo de aprobación doctrinal y la documentación técnica con el resto del módulo - 22/07/2026
// Sal-B: implementar lógica principal del cierre del flujo de aprobación doctrinal y la documentación técnica - 22/07/2026
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
    // Sal-B: corregir bug detectado en pruebas de la estructura inicial del flujo de aprobación doctrinal - 06/07/2026
    if (!mounted) return;
    if (result != null) {
      setState(() {
        _isApproved = result;
      });
    }
  }

  // Sal-B: refactorizar código de la estructura inicial del flujo de aprobación doctrinal - 07/07/2026
  Widget _buildStatusIcon() {
    return Icon(
      _isApproved ? Icons.verified : Icons.warning_amber_rounded,
      size: 64,
      color: _isApproved ? Colors.green : Colors.orange,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sal-B: ajustar UI/UX de la estructura inicial del flujo de aprobación doctrinal - 03/07/2026
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Aprobación Doctrinal'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatusIcon(),
                const SizedBox(height: 16),
                Text(
                  'Estado de Aprobación: ${_isApproved ? "APROBADO" : "PENDIENTE"}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isApproved ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _showApprovalDialog,
                  icon: const Icon(Icons.rate_review),
                  label: const Text('Iniciar Evaluación'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// Sal-B: aplicar comentarios de revisión cruzada en la estructura inicial del flujo de aprobación doctrinal - 06/07/2026
