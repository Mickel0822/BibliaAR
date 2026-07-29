import 'package:biblia_ar_flutter/data/models/certificado_conadis.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/conadis_repository.dart';
import 'package:biblia_ar_flutter/features/egov/conadis/conadis_formato_validator.dart';
import 'package:flutter/foundation.dart';
// kguanoluisa, Provider de estado para consulta CONADIS offline con validacion y guardado opt-in, variables v_consultando y v_ultimoResultado, 2026-07-29
class ConadisProvider extends ChangeNotifier {
  ConadisProvider({required ConadisRepository conadisRepository})
      : _conadisRepository = conadisRepository;

  final ConadisRepository _conadisRepository;

  bool vConsultando = false;
  CertificadoConadis? vUltimoResultado;

  bool validarFormato(String numero) {
    return ConadisFormatoValidator.esFormatoValido(numero);
  }

  Future<CertificadoConadis?> consultar(String numero) async {
    vConsultando = true;
    notifyListeners();

    try {
      final normalizado = ConadisFormatoValidator.normalizar(numero);
      final resultado = await _conadisRepository.consultarPorNumero(normalizado);
      vUltimoResultado = resultado;
      return resultado;
    } finally {
      vConsultando = false;
      notifyListeners();
    }
  }

  Future<void> guardarConsulta({
    required int perfilId,
    required CertificadoConadis certificado,
  }) async {
    await _conadisRepository.guardarConsulta(
      perfilId: perfilId,
      certificado: certificado,
    );
  }
}
