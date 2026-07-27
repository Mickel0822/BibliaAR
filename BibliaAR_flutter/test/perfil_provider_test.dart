import 'package:biblia_ar_flutter/data/models/configuracion_sensorial.dart';
import 'package:biblia_ar_flutter/data/models/perfil.dart';
import 'package:biblia_ar_flutter/data/models/tipo_usuario.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/configuracion_repository.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/perfil_repository.dart';
import 'package:biblia_ar_flutter/features/profiles/perfil_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class FakePerfilRepository implements PerfilRepository {
  final List<Perfil> perfiles = [];

  @override
  Future<Perfil> crear(Perfil perfil) async {
    final creado = perfil.copyWith(id: perfiles.length + 1);
    perfiles.add(creado);
    return creado;
  }

  @override
  Future<void> eliminar(int id) async {
    perfiles.removeWhere((perfil) => perfil.id == id);
  }

  @override
  Future<Perfil?> obtenerPorId(int id) async {
    for (final perfil in perfiles) {
      if (perfil.id == id) {
        return perfil;
      }
    }
    return null;
  }

  @override
  Future<List<Perfil>> obtenerPorTipo(String tipoUsuario) async {
    return perfiles.where((perfil) => perfil.tipoUsuario.value == tipoUsuario).toList();
  }

  @override
  Future<List<Perfil>> obtenerTodos() async => perfiles;

  @override
  Future<int?> obtenerPerfilActivoId() async => null;

  @override
  Future<void> guardarPerfilActivoId(int perfilId) async {}

  @override
  Future<void> limpiarPerfilActivo() async {}
}

class FakeConfiguracionRepository implements ConfiguracionRepository {
  @override
  Future<ConfiguracionSensorial> crearPorDefecto(int perfilId) async {
    return ConfiguracionSensorial(perfilId: perfilId);
  }

  @override
  Future<ConfiguracionSensorial?> obtenerPorPerfil(int perfilId) async => null;

  @override
  Future<void> guardar(ConfiguracionSensorial configuracion) async {}
}

void main() {
  test('PerfilProvider crea perfil de nino', () async {
    final provider = PerfilProvider(
      perfilRepository: FakePerfilRepository(),
      configuracionRepository: FakeConfiguracionRepository(),
    );

    final perfil = await provider.crearPerfil(
      nombre: 'Ana',
      tipoUsuario: TipoUsuario.nino,
    );

    expect(perfil.nombre, 'Ana');
    expect(perfil.tipoUsuario, TipoUsuario.nino);
    expect(provider.vPerfiles.length, 1);
  });
}
