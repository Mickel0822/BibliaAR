// kguanoluisa, Estructura base del validador de formato del numero de certificado CONADIS CON-YYYY-NNNNNN, variable v_patronConadis, 2026-07-27
class ConadisFormatoValidator {
  static final RegExp vPatronConadis = RegExp(r'^CON-\d{4}-\d{6}$');

  static bool esFormatoValido(String numero) {
    return vPatronConadis.hasMatch(numero.trim().toUpperCase());
  }
}
