// Cristian Bayas, Modelo de certificado CONADIS simulado, cbayas0410@gmail.com, BIAR-63
class CertificadoConadis {
  const CertificadoConadis({
    required this.numeroCertificado,
    required this.tipoDiscapacidad,
    required this.porcentaje,
    this.nombreTitular,
  });

  final String numeroCertificado;
  final String tipoDiscapacidad;
  final int porcentaje;
  final String? nombreTitular;

  bool get esDiscapacidadAuditiva =>
      tipoDiscapacidad == 'auditiva' || tipoDiscapacidad == 'multiple';

  }
