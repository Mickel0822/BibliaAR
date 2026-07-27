import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/features/profiles/historial_actividades_provider.dart';
import 'package:biblia_ar_flutter/features/profiles/perfil_provider.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_empty_view.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_error_view.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_loading_view.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_section_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Pantalla de historial de actividades del perfil (BIAR-44).
///
/// Muestra intentos previos con resultado y fecha para apoyar
/// el seguimiento pedagógico en el panel Flutter.
class HistorialActividadesScreen extends StatefulWidget {
  const HistorialActividadesScreen({super.key});

  @override
  State<HistorialActividadesScreen> createState() =>
      _HistorialActividadesScreenState();
}

class _HistorialActividadesScreenState extends State<HistorialActividadesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  Future<void> _cargar() async {
    final perfil = context.read<PerfilProvider>().vPerfilActivo;
    if (perfil?.id == null) return;
    await context.read<HistorialActividadesProvider>().cargarHistorial(perfil!.id!);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HistorialActividadesProvider>();
    final perfil = context.watch<PerfilProvider>().vPerfilActivo;

    return Scaffold(
      appBar: AppBar(
        title: Text('Historial · ${perfil?.nombre ?? 'Perfil'}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(BiarSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const BiarSectionHeader(
              vTitulo: 'Actividades realizadas',
              vSubtitulo: 'Intentos registrados en este perfil',
              vIcono: Icons.history,
            ),
            const SizedBox(height: BiarSpacing.md),
            Expanded(child: _buildBody(provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(HistorialActividadesProvider provider) {
    if (provider.vCargando) {
      return const BiarLoadingView(vMensaje: 'Cargando historial...');
    }
    if (provider.vError != null) {
      return BiarErrorView(
        vMensaje: provider.vError!,
        onReintentar: _cargar,
      );
    }
    if (provider.vHistorial.isEmpty) {
      return const BiarEmptyView(
        vMensaje: 'Completa una lección para ver tu historial aquí',
        vIcono: Icons.history_toggle_off,
      );
    }

    return ListView.separated(
      itemCount: provider.vHistorial.length,
      separatorBuilder: (_, __) => const SizedBox(height: BiarSpacing.sm),
      itemBuilder: (context, index) {
        final entry = provider.vHistorial[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text('${entry.intentoNumero}'),
            ),
            title: Text(entry.tituloActividad),
            subtitle: Text(
              '${entry.resultado} · ${_formatFecha(entry.fecha)}',
            ),
            trailing: Icon(
              entry.resultado == 'correcto' ? Icons.check_circle : Icons.replay,
              color: entry.resultado == 'correcto' ? Colors.green : Colors.orange,
            ),
          ),
        );
      },
    );
  }

  String _formatFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }
}
