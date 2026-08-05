import 'package:biblia_ar_flutter/core/constants/auth_credentials.dart';
import 'package:biblia_ar_flutter/data/models/tipo_usuario.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// kguanoluisa, Provider de autenticacion local con persistencia de sesion en SharedPreferences, variables v_usuario, v_rol y v_autenticado, 2026-07-23
class AuthProvider extends ChangeNotifier {
  static const String vPrefAutenticado = 'auth_autenticado';
  static const String vPrefUsuario = 'auth_usuario';
  static const String vPrefRol = 'auth_rol';

  bool vAutenticado = false;
  String? vUsuario;
  TipoUsuario? vRol;
  bool vCargando = false;
  String? vError;

  Future<void> cargarSesion() async {
    vCargando = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    vAutenticado = prefs.getBool(vPrefAutenticado) ?? false;
    vUsuario = prefs.getString(vPrefUsuario);
    final rol = prefs.getString(vPrefRol);
    vRol = rol != null ? TipoUsuario.fromValue(rol) : null;

    vCargando = false;
    notifyListeners();
  }

  Future<bool> iniciarSesion({
    required String usuario,
    required String clave,
  }) async {
    vError = null;
    final rol = AuthCredentials.validar(usuario, clave);
    if (rol == null) {
      vError = 'Usuario o contraseña incorrectos';
      notifyListeners();
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(vPrefAutenticado, true);
    await prefs.setString(vPrefUsuario, usuario.trim().toLowerCase());
    await prefs.setString(vPrefRol, rol.value);

    vAutenticado = true;
    vUsuario = usuario.trim().toLowerCase();
    vRol = rol;
    notifyListeners();
    return true;
  }

  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(vPrefAutenticado);
    await prefs.remove(vPrefUsuario);
    await prefs.remove(vPrefRol);

    vAutenticado = false;
    vUsuario = null;
    vRol = null;
    vError = null;
    notifyListeners();
  }
}
