import 'package:biblia_ar_flutter/data/models/actividad.dart';
import 'package:biblia_ar_flutter/data/models/resultado_actividad.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/actividad_repository.dart';
import 'package:flutter/foundation.dart';

// kguanoluisa, Provider de actividades interactivas con registro de intentos sin penalizacion, variables v_actividades y v_indiceActividad, 2026-07-23
class ActividadProvider extends ChangeNotifier {
  ActividadProvider({required ActividadRepository actividadRepository})
      : _actividadRepository = actividadRepository;

  final ActividadRepository _actividadRepository;

  List<Actividad> vActividades = [];
  int vIndiceActividad = 0;
  bool vCargando = false;

  Future<void> cargarActividades(int leccionId) async {
    vCargando = true;
    notifyListeners();
    vActividades = await _actividadRepository.obtenerPorLeccion(leccionId);
    vCargando = false;
    notifyListeners();
  }

  Future<void> registrarIntento({
    required int perfilId,
    required int actividadId,
    required String resultado,
  }) async {
    final intentos = await _actividadRepository.contarIntentos(perfilId, actividadId);
    await _actividadRepository.guardarResultado(
      ResultadoActividad(
        perfilId: perfilId,
        actividadId: actividadId,
        resultado: resultado,
        intentoNumero: intentos + 1,
        fecha: DateTime.now(),
      ),
    );
  }
}
