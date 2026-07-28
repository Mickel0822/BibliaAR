import 'package:biblia_ar_flutter/features/egov/conadis/conadis_formato_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('acepta formato valido CON-AAAA-NNNNNN', () {
    expect(ConadisFormatoValidator.esFormatoValido('CON-2024-000001'), isTrue);
    expect(ConadisFormatoValidator.esFormatoValido('con-2024-000001'), isTrue);
    expect(ConadisFormatoValidator.esFormatoValido('  CON-2023-000015  '), isTrue);
  });

  test('rechaza formatos invalidos', () {
    expect(ConadisFormatoValidator.esFormatoValido(''), isFalse);
    expect(ConadisFormatoValidator.esFormatoValido('CON-2024-001'), isFalse);
    expect(ConadisFormatoValidator.esFormatoValido('2024-000001'), isFalse);
    expect(ConadisFormatoValidator.esFormatoValido('CON-24-000001'), isFalse);
    expect(ConadisFormatoValidator.esFormatoValido('CON-2024-ABCDEF'), isFalse);
  });

  test('normalizar convierte a mayusculas y recorta espacios', () {
    expect(
      ConadisFormatoValidator.normalizar('  con-2024-000001  '),
      'CON-2024-000001',
    );
  });
}
