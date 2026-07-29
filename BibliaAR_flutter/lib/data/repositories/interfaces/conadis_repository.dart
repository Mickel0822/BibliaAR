import 'package:biblia_ar_flutter/data/models/certificado_conadis.dart';

// kguanoluisa, Interfaz de repositorio para consulta y guardado opt-in de certificados CONADIS, sin nuevas variables, 2026-07-29
abstract class ConadisRepository {
  Future<CertificadoConadis?> consultarPorNumero(String numeroCertificado);

  Future<void> guardarConsulta({
    required int perfilId,
    required CertificadoConadis certificado,
  });
}
