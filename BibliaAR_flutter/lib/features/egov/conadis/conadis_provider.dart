import 'package:biblia_ar_flutter/data/models/certificado_conadis.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/conadis_repository.dart';
import 'package:flutter/foundation.dart';

// Cristian Bayas, Provider CONADIS guardado opt-in, cbayas0410@gmail.com, BIAR-65
class ConadisProvider extends ChangeNotifier {
  ConadisProvider({required ConadisRepository conadisRepository})
      : _conadisRepository = conadisRepository;

  final ConadisRepository _conadisRepository;

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
