import 'package:biblia_ar_flutter/features/egov/conadis/conadis_formato_validator.dart';
import 'package:flutter/foundation.dart';

// kguanoluisa, Provider de validacion de formato CONADIS integrado al modulo eGovernment, sin nuevas variables, 2026-07-27
class ConadisProvider extends ChangeNotifier {
  bool validarFormato(String numero) {
    return ConadisFormatoValidator.esFormatoValido(numero);
  }
}
