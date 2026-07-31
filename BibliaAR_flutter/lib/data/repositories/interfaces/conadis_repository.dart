import 'package:biblia_ar_flutter/data/models/certificado_conadis.dart';

// Cristian Bayas, Interfaz CONADIS consulta offline, cbayas0410@gmail.com, BIAR-63
abstract class ConadisRepository {
  Future<CertificadoConadis?> consultarPorNumero(String numeroCertificado);

  Future<void> guardarConsulta({
    required int perfilId,
    required CertificadoConadis certificado,
  });
}
