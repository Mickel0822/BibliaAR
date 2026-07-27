import 'package:biblia_ar_flutter/data/models/historial_actividad_entry.dart';

/// Contrato de acceso al historial de actividades por perfil (BIAR-44).
///
/// Abstrae la persistencia local (sqflite) para listar intentos
/// y registrar nuevos resultados desde el módulo de actividades.
abstract class HistorialActividadRepository {
  /// Obtiene el historial ordenado por fecha descendente.
  Future<List<HistorialActividadEntry>> obtenerPorPerfil(int perfilId);

  /// Registra un nuevo intento en el historial del perfil.
  Future<void> registrarIntento(HistorialActividadEntry entry);

  /// Cuenta intentos previos para una actividad concreta.
  Future<int> contarIntentos(int perfilId, int actividadId);
}
