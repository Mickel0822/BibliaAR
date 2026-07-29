import 'package:biblia_ar_flutter/data/models/certificado_conadis.dart';
import 'package:biblia_ar_flutter/data/models/fragmento_narrativo.dart';

// Cristian Bayas, Fragmento resultado CONADIS con tipo y porcentaje, cbayas0410@gmail.com, BIAR-63
class ConadisFragmentBuilder {
  static List<FragmentoNarrativo> construirFragmentosResultado({
    required CertificadoConadis certificado,
  }) {
    final pictogramaTipo = certificado.tipoDiscapacidad;

    return [
      FragmentoNarrativo(
        id: 1,
        titulo: 'Certificado encontrado',
        descripcion:
            '${certificado.etiquetaTipoDiscapacidad}: ${certificado.porcentaje}% certificado.',
        ilustracionAsset: '',
        videoLseAsset: '',
        audioAsset: '',
        duracionMs: 5000,
        pictogramas: ['certificado', pictogramaTipo],
        textoSubtitulo:
            'Tipo: ${certificado.etiquetaTipoDiscapacidad}. Porcentaje certificado: ${certificado.porcentaje}%.',
      ),
    ];
  }
}
