import 'package:biblia_ar_flutter/data/models/configuracion_sensorial.dart';

abstract class ConfiguracionRepository {
  Future<ConfiguracionSensorial?> obtenerPorPerfil(int perfilId);
  Future<void> guardar(ConfiguracionSensorial configuracion);
  Future<ConfiguracionSensorial> crearPorDefecto(int perfilId);
}
