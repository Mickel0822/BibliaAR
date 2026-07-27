// kguanoluisa, Logica principal de normalizacion y mensaje de error para formato CONADIS, sin nuevas variables, 2026-07-27
class ConadisFormatoValidator {
  static final RegExp vPatronConadis = RegExp(r'^CON-\d{4}-\d{6}$');

  static bool esFormatoValido(String numero) {
    return vPatronConadis.hasMatch(numero.trim().toUpperCase());
  }

  static String normalizar(String numero) {
    return numero.trim().toUpperCase();
  }

  static const String mensajeFormatoInvalido =
      'El nÃºmero debe tener el formato CON-AAAA-NNNNNN. Ejemplo: CON-2024-000001';
}
