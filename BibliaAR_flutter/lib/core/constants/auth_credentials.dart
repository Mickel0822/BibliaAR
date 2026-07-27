import 'package:biblia_ar_flutter/data/models/tipo_usuario.dart';

// kguanoluisa, Credenciales locales de acceso para roles nino y docente en fase 1, variables v_usuarioNino, v_claveNino, v_usuarioDocente y v_claveDocente, 2026-07-23
class AuthCredentials {
  static const String vUsuarioNino = 'nino_biar';
  static const String vClaveNino = 'biar2026';
  static const String vUsuarioDocente = 'docente_biar';
  static const String vClaveDocente = 'ibjn2026';

  static TipoUsuario? validar(String usuario, String clave) {
    final usuarioNormalizado = usuario.trim().toLowerCase();
    if (usuarioNormalizado == vUsuarioNino && clave == vClaveNino) {
      return TipoUsuario.nino;
    }
    if (usuarioNormalizado == vUsuarioDocente && clave == vClaveDocente) {
      return TipoUsuario.docente;
    }
    return null;
  }
}
