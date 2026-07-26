import 'package:biblia_ar_flutter/data/models/configuracion_sensorial.dart';
import 'package:biblia_ar_flutter/data/models/perfil.dart';
import 'package:biblia_ar_flutter/data/models/tipo_usuario.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/configuracion_repository.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/perfil_repository.dart';
import 'package:flutter/foundation.dart';

// kguanoluisa, Provider de perfiles con seleccion y creacion local sin autenticacion, variables v_perfilActivo y v_perfiles, 2026-07-23
class PerfilProvider extends ChangeNotifier {
  PerfilProvider({
    required PerfilRepository perfilRepository,
    required ConfiguracionRepository configuracionRepository,
  })  : _perfilRepository = perfilRepository,
        _configuracionRepository = configuracionRepository;

  final PerfilRepository _perfilRepository;
  final ConfiguracionRepository _configuracionRepository;

  List<Perfil> vPerfiles = [];
  Perfil? vPerfilActivo;
  bool vCargando = false;
  String? vError;

  Future<void> cargarPerfiles() async {
    vCargando = true;
    vError = null;
    notifyListeners();

    try {
      vPerfiles = await _perfilRepository.obtenerTodos();
      final activoId = await _perfilRepository.obtenerPerfilActivoId();
      if (activoId != null) {
        vPerfilActivo = await _perfilRepository.obtenerPorId(activoId);
      }
    } catch (error) {
      vError = error.toString();
    } finally {
      vCargando = false;
      notifyListeners();
    }
  }

  Future<Perfil> crearPerfil({
    required String nombre,
    required TipoUsuario tipoUsuario,
  }) async {
    final perfil = Perfil(
      nombre: nombre.trim(),
      tipoUsuario: tipoUsuario,
      creadoEn: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final creado = await _perfilRepository.crear(perfil);
    await _configuracionRepository.crearPorDefecto(creado.id!);
    vPerfiles = await _perfilRepository.obtenerTodos();
    notifyListeners();
    return creado;
  }

  Future<void> seleccionarPerfil(Perfil perfil) async {
    vPerfilActivo = perfil;
    await _perfilRepository.guardarPerfilActivoId(perfil.id!);
    notifyListeners();
  }

  Future<void> cerrarSesionPerfil() async {
    vPerfilActivo = null;
    await _perfilRepository.limpiarPerfilActivo();
    notifyListeners();
  }

  List<Perfil> perfilesNinos() {
    return vPerfiles
        .where((perfil) => perfil.tipoUsuario == TipoUsuario.nino)
        .toList();
  }

  // kguanoluisa, Resuelve o crea el perfil activo segun el rol autenticado sin pantalla de seleccion, variable v_tipoUsuario, 2026-07-23
  Future<Perfil> resolverPerfilDesdeSesion({
    required TipoUsuario vTipoUsuario,
  }) async {
    await cargarPerfiles();

    final nombrePerfil = vTipoUsuario == TipoUsuario.docente ? 'Docente' : 'Niño';
    Perfil? perfilExistente;
    for (final perfil in vPerfiles) {
      if (perfil.tipoUsuario == vTipoUsuario &&
          perfil.nombre.toLowerCase() == nombrePerfil.toLowerCase()) {
        perfilExistente = perfil;
        break;
      }
    }

    if (perfilExistente != null) {
      await seleccionarPerfil(perfilExistente);
      return perfilExistente;
    }

    final perfilCreado = await crearPerfil(
      nombre: nombrePerfil,
      tipoUsuario: vTipoUsuario,
    );
    await seleccionarPerfil(perfilCreado);
    return perfilCreado;
  }
}

// kguanoluisa, Provider de configuracion sensorial persistente por perfil, variable v_configuracion, 2026-07-23
class ConfiguracionProvider extends ChangeNotifier {
  ConfiguracionProvider({required ConfiguracionRepository configuracionRepository})
      : _configuracionRepository = configuracionRepository;

  final ConfiguracionRepository _configuracionRepository;
  ConfiguracionSensorial? vConfiguracion;

  Future<void> cargar(int perfilId) async {
    vConfiguracion = await _configuracionRepository.obtenerPorPerfil(perfilId);
    vConfiguracion ??= await _configuracionRepository.crearPorDefecto(perfilId);
    notifyListeners();
  }

  Future<void> actualizar(ConfiguracionSensorial configuracion) async {
    vConfiguracion = configuracion.copyWith(updatedAt: DateTime.now());
    await _configuracionRepository.guardar(vConfiguracion!);
    notifyListeners();
  }

  Future<void> toggleLse(bool value) async {
    if (vConfiguracion == null) return;
    await actualizar(vConfiguracion!.copyWith(lseActivo: value));
  }

  Future<void> toggleSubtitulos(bool value) async {
    if (vConfiguracion == null) return;
    await actualizar(vConfiguracion!.copyWith(subtitulosActivos: value));
  }

  Future<void> toggleAudio(bool value) async {
    if (vConfiguracion == null) return;
    await actualizar(vConfiguracion!.copyWith(audioActivo: value));
  }

  Future<void> togglePictogramas(bool value) async {
    if (vConfiguracion == null) return;
    await actualizar(vConfiguracion!.copyWith(pictogramasActivos: value));
  }

  Future<void> actualizarVelocidad(double velocidad) async {
    if (vConfiguracion == null) return;
    await actualizar(vConfiguracion!.copyWith(velocidadAudio: velocidad));
  }

  Future<void> actualizarVolumen(double volumen) async {
    if (vConfiguracion == null) return;
    await actualizar(vConfiguracion!.copyWith(volumenAudio: volumen));
  }
}
