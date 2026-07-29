// kguanoluisa, Validador de formato de numero de certificado CONADIS con regex CON-YYYY-NNNNNN, variable v_patronConadis, 2026-07-29
class ConadisFormatoValidator {
  static final RegExp vPatronConadis = RegExp(r'^CON-\d{4}-\d{6}$');

  static bool esFormatoValido(String numero) {
    return vPatronConadis.hasMatch(numero.trim().toUpperCase());
  }

  static String normalizar(String numero) {
    return numero.trim().toUpperCase();
  }

  static const String mensajeFormatoInvalido =
      'El número debe tener el formato CON-AAAA-NNNNNN. Ejemplo: CON-2024-000001';
}
