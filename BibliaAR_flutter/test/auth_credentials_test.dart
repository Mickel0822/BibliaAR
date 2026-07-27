import 'package:biblia_ar_flutter/core/constants/auth_credentials.dart';
import 'package:biblia_ar_flutter/data/models/tipo_usuario.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AuthCredentials valida usuario nino', () {
    final rol = AuthCredentials.validar(
      AuthCredentials.vUsuarioNino,
      AuthCredentials.vClaveNino,
    );
    expect(rol, TipoUsuario.nino);
  });

  test('AuthCredentials valida usuario docente', () {
    final rol = AuthCredentials.validar(
      AuthCredentials.vUsuarioDocente,
      AuthCredentials.vClaveDocente,
    );
    expect(rol, TipoUsuario.docente);
  });

  test('AuthCredentials rechaza credenciales invalidas', () {
    final rol = AuthCredentials.validar('admin', '1234');
    expect(rol, isNull);
  });
}
