import 'package:biblia_ar_flutter/data/models/perfil.dart';

abstract class PerfilRepository {
  Future<List<Perfil>> obtenerTodos();
  Future<List<Perfil>> obtenerPorTipo(String tipoUsuario);
  Future<Perfil?> obtenerPorId(int id);
  Future<Perfil> crear(Perfil perfil);
  Future<void> eliminar(int id);
  Future<int?> obtenerPerfilActivoId();
  Future<void> guardarPerfilActivoId(int perfilId);
  Future<void> limpiarPerfilActivo();
}
