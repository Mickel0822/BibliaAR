import 'dart:io';

import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/core/feedback/multimodal_feedback.dart';
import 'package:biblia_ar_flutter/features/egov/document_upload_service.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Pantalla de tramites eGovernment para subir cualquier documento localmente, variables v_documentosSeleccionados y v_documentosGuardados, 2026-07-23
class TramitesUploadScreen extends StatefulWidget {
  const TramitesUploadScreen({super.key});

  @override
  State<TramitesUploadScreen> createState() => _TramitesUploadScreenState();
}

class _TramitesUploadScreenState extends State<TramitesUploadScreen> {
  final DocumentUploadService _uploadService = DocumentUploadService();
  final List<PlatformFile> vDocumentosSeleccionados = [];
  List<File> vDocumentosGuardados = [];
  bool vListando = false;
  bool vGuardando = false;
  String? vError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarGuardados());
  }

  Future<void> _cargarGuardados() async {
    if (!mounted) return;
    setState(() {
      vListando = true;
      vError = null;
    });

    try {
      final archivos = await _uploadService.listarDocumentosGuardados();
      if (!mounted) return;
      setState(() {
        vDocumentosGuardados = archivos;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => vError = 'No se pudieron cargar los documentos: $error');
    } finally {
      if (mounted) setState(() => vListando = false);
    }
  }

  Future<void> _seleccionarDocumentos() async {
    try {
      final resultado = await FilePicker.pickFiles(
        allowMultiple: true,
        type: FileType.any,
        withData: true,
      );
      if (resultado == null || resultado.files.isEmpty) return;

      setState(() {
        for (final archivo in resultado.files) {
          if (archivo.path != null || archivo.bytes != null) {
            vDocumentosSeleccionados.add(archivo);
          }
        }
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el selector: $error')),
      );
    }
  }

  Future<void> _guardarDocumentos() async {
    if (vDocumentosSeleccionados.isEmpty) return;

    setState(() => vGuardando = true);
    try {
      for (final archivo in vDocumentosSeleccionados) {
        if (archivo.path != null) {
          await _uploadService.guardarDocumento(
            vRutaOrigen: archivo.path!,
            vNombreArchivo: archivo.name,
          );
        } else if (archivo.bytes != null) {
          await _uploadService.guardarBytes(
            vBytes: archivo.bytes!,
            vNombreArchivo: archivo.name,
          );
        }
      }
      if (!mounted) return;
      vDocumentosSeleccionados.clear();
      await _cargarGuardados();
      if (!mounted) return;
      await MultimodalFeedback.success(
        context,
        mensaje: 'Documentos guardados correctamente',
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar: $error')),
      );
    } finally {
      if (mounted) setState(() => vGuardando = false);
    }
  }

  String _formatoTamano(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _nombreArchivo(File file) {
    final segmentos = file.uri.pathSegments;
    if (segmentos.isEmpty) return file.path;
    return segmentos.last;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trámites accesibles')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(BiarSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(BiarModuleIcons.tramites, size: 40),
                const SizedBox(width: BiarSpacing.sm),
                Expanded(
                  child: Text(
                    'Sube cualquier documento para tu trámite municipal',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: BiarSpacing.md),
            BiarButton(
              label: 'Seleccionar documento',
              icon: Icons.upload_file,
              onPressed: _seleccionarDocumentos,
            ),
            if (vDocumentosSeleccionados.isNotEmpty) ...[
              const SizedBox(height: BiarSpacing.lg),
              Text(
                'Listos para guardar',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: BiarSpacing.sm),
              ...vDocumentosSeleccionados.map((archivo) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.insert_drive_file),
                    title: Text(archivo.name),
                    subtitle: Text(_formatoTamano(archivo.size)),
                  ),
                );
              }),
              const SizedBox(height: BiarSpacing.sm),
              BiarButton(
                label: vGuardando ? 'Guardando...' : 'Guardar documentos',
                icon: Icons.save,
                onPressed: vGuardando ? null : _guardarDocumentos,
              ),
            ],
            const SizedBox(height: BiarSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Documentos guardados',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (vListando)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: BiarSpacing.sm),
            if (vError != null)
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(BiarSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(vError!),
                      const SizedBox(height: BiarSpacing.sm),
                      BiarButton(
                        label: 'Reintentar',
                        icon: Icons.refresh,
                        expanded: false,
                        onPressed: _cargarGuardados,
                      ),
                    ],
                  ),
                ),
              )
            else if (vListando && vDocumentosGuardados.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: BiarSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: BiarSpacing.sm),
                    Text('Cargando documentos...'),
                  ],
                ),
              )
            else if (vDocumentosGuardados.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(BiarSpacing.lg),
                  child: Row(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: BiarSpacing.sm),
                      const Expanded(
                        child: Text('Aún no has subido documentos.'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...vDocumentosGuardados.map((file) {
                final stat = file.statSync();
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(_nombreArchivo(file)),
                    subtitle: Text(_formatoTamano(stat.size)),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
