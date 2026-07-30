import 'package:biblia_ar_flutter/data/models/certificado_conadis.dart';
import 'package:biblia_ar_flutter/features/egov/conadis/conadis_fragment_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const certificado = CertificadoConadis(
    numeroCertificado: 'CON-2024-000001',
    tipoDiscapacidad: 'auditiva',
    porcentaje: 85,
  );

  test('resultado muestra un solo fragmento con porcentaje exacto', () {
    final fragmentos = ConadisFragmentBuilder.construirFragmentosResultado(
      certificado: certificado,
    );

    expect(fragmentos, hasLength(1));
    expect(fragmentos.first.descripcion, contains('85%'));
    expect(fragmentos.first.textoSubtitulo, contains('85%'));
    expect(fragmentos.first.descripcion, contains('auditiva'));
  });
}
