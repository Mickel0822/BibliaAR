import 'package:biblia_ar_flutter/data/models/leccion.dart';
import 'package:biblia_ar_flutter/data/models/leccion_categoria.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/leccion_repository.dart';
import 'package:flutter/foundation.dart';

// kguanoluisa, Constantes de validacion para lecciones creadas por docente, sin nuevas variables, 2026-07-23
class LeccionDocenteValidacion {
  static const int maxTitulo = 80;
  static const int maxHistoria = 2000;
  static const int maxVersiculoReferencia = 100;
  static const int maxVersiculoTexto = 500;
}

// kguanoluisa, Provider de lecciones biblicas con creacion docente y refresco automatico, variables v_leccionesBiblicas y v_cargando, 2026-07-23
class LeccionProvider extends ChangeNotifier {
  LeccionProvider({required LeccionRepository leccionRepository})
      : _leccionRepository = leccionRepository;

  final LeccionRepository _leccionRepository;

  List<Leccion> vLeccionesBiblicas = [];
  bool vCargando = false;
  String? vError;

  Future<void> cargarLeccionesBiblicas() async {
    vCargando = true;
    vError = null;
    notifyListeners();

    try {
      vLeccionesBiblicas =
          await _leccionRepository.obtenerPorCategoria(LeccionCategoria.biblico);
    } catch (error) {
      vError = error.toString();
    } finally {
      vCargando = false;
      notifyListeners();
    }
  }

  String? validarCampos({
    required String titulo,
    required String historiaTexto,
    required String versiculoReferencia,
    required String versiculoTexto,
  }) {
    if (titulo.trim().isEmpty) {
      return 'El título es obligatorio';
    }
    if (titulo.trim().length > LeccionDocenteValidacion.maxTitulo) {
      return 'El título no puede superar ${LeccionDocenteValidacion.maxTitulo} caracteres';
    }
    if (historiaTexto.trim().isEmpty) {
      return 'El texto de la historia es obligatorio';
    }
    if (historiaTexto.trim().length > LeccionDocenteValidacion.maxHistoria) {
      return 'La historia no puede superar ${LeccionDocenteValidacion.maxHistoria} caracteres';
    }
    if (versiculoReferencia.trim().isEmpty) {
      return 'La referencia del versículo es obligatoria';
    }
    if (versiculoReferencia.trim().length > LeccionDocenteValidacion.maxVersiculoReferencia) {
      return 'La referencia no puede superar ${LeccionDocenteValidacion.maxVersiculoReferencia} caracteres';
    }
    if (versiculoTexto.trim().isEmpty) {
      return 'El texto del versículo es obligatorio';
    }
    if (versiculoTexto.trim().length > LeccionDocenteValidacion.maxVersiculoTexto) {
      return 'El versículo no puede superar ${LeccionDocenteValidacion.maxVersiculoTexto} caracteres';
    }
    return null;
  }

  Future<Leccion?> crearLeccionDocente({
    required String titulo,
    required String historiaTexto,
    required String versiculoReferencia,
    required String versiculoTexto,
    String pictograma = 'historias',
  }) async {
    final errorValidacion = validarCampos(
      titulo: titulo,
      historiaTexto: historiaTexto,
      versiculoReferencia: versiculoReferencia,
      versiculoTexto: versiculoTexto,
    );
    if (errorValidacion != null) {
      vError = errorValidacion;
      notifyListeners();
      return null;
    }

    try {
      final maxOrden = await _leccionRepository.obtenerMaxOrden();
      final leccion = await _leccionRepository.crear(
        Leccion(
          titulo: titulo.trim(),
          referenciaBiblica: versiculoReferencia.trim(),
          contenidoMultimediaPath: '',
          categoria: LeccionCategoria.biblico,
          orden: maxOrden + 1,
          historiaTexto: historiaTexto.trim(),
          versiculoReferencia: versiculoReferencia.trim(),
          versiculoTexto: versiculoTexto.trim(),
          pictograma: pictograma,
        ),
      );
      await cargarLeccionesBiblicas();
      return leccion;
    } catch (error) {
      vError = error.toString();
      notifyListeners();
      return null;
    }
  }
}
