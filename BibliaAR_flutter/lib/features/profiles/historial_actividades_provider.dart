import 'package:biblia_ar_flutter/data/models/historial_actividad_entry.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/historial_actividad_repository.dart';
import 'package:flutter/foundation.dart';

/// Provider del historial de actividades del perfil activo (BIAR-44).
///
/// Expone la lista de intentos registrados y coordina la recarga
/// cuando el usuario completa actividades en el módulo educativo.
class HistorialActividadesProvider extends ChangeNotifier {
  HistorialActividadesProvider({
    required HistorialActividadRepository historialRepository,
  }) : _historialRepository = historialRepository;

  final HistorialActividadRepository _historialRepository;

  List<HistorialActividadEntry> vHistorial = [];
  bool vCargando = false;
  String? vError;

  /// Carga el historial completo del perfil indicado.
  Future<void> cargarHistorial(int perfilId) async {
    vCargando = true;
    vError = null;
    notifyListeners();

    try {
      vHistorial = await _historialRepository.obtenerPorPerfil(perfilId);
    } catch (error) {
      vError = error.toString();
      vHistorial = [];
    } finally {
      vCargando = false;
      notifyListeners();
    }
  }

  /// Registra un nuevo intento y actualiza la lista en memoria.
  Future<void> registrarIntento(HistorialActividadEntry entry) async {
    await _historialRepository.registrarIntento(entry);
    vHistorial = await _historialRepository.obtenerPorPerfil(entry.perfilId);
    notifyListeners();
  }
}
