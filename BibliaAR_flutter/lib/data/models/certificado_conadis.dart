// kguanoluisa, Modelo de certificado CONADIS simulado con tipo de discapacidad y porcentaje, sin nuevas variables, 2026-07-29
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

  factory CertificadoConadis.fromMap(Map<String, dynamic> map) {
    return CertificadoConadis(
      numeroCertificado: map['numero_certificado'] as String,
      tipoDiscapacidad: map['tipo_discapacidad'] as String,
      porcentaje: map['porcentaje'] as int,
      nombreTitular: map['nombre_titular'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'numero_certificado': numeroCertificado,
      'tipo_discapacidad': tipoDiscapacidad,
      'porcentaje': porcentaje,
      'nombre_titular': nombreTitular,
    };
  }

  String get etiquetaTipoDiscapacidad {
    switch (tipoDiscapacidad) {
      case 'auditiva':
        return 'Discapacidad auditiva';
      case 'visual':
        return 'Discapacidad visual';
      case 'motriz':
        return 'Discapacidad motriz';
      case 'intelectual':
        return 'Discapacidad intelectual';
      case 'multiple':
        return 'Discapacidad múltiple';
      default:
        return tipoDiscapacidad;
    }
  }
}
