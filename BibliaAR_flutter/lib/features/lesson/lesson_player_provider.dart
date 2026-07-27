import 'dart:convert';

import 'package:biblia_ar_flutter/core/constants/app_constants.dart';
import 'package:biblia_ar_flutter/data/models/estado_progreso.dart';
import 'package:biblia_ar_flutter/data/models/fragmento_narrativo.dart';
import 'package:biblia_ar_flutter/data/models/leccion.dart';
import 'package:biblia_ar_flutter/data/models/progreso.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/leccion_repository.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/progreso_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// kguanoluisa, Provider del reproductor de leccion multimedia con fragmentos narrativos sincronizados, variables v_fragmentos y v_indiceFragmento, 2026-07-23
class LessonPlayerProvider extends ChangeNotifier {
  LessonPlayerProvider({
    required LeccionRepository leccionRepository,
    required ProgresoRepository progresoRepository,
  })  : _leccionRepository = leccionRepository,
        _progresoRepository = progresoRepository;

  final LeccionRepository _leccionRepository;
  final ProgresoRepository _progresoRepository;

  Leccion? vLeccion;
  List<FragmentoNarrativo> vFragmentos = [];
  int vIndiceFragmento = 0;
  bool vReproduciendo = false;
  bool vCargando = false;
  String? vError;

  FragmentoNarrativo? get fragmentoActual {
    if (vFragmentos.isEmpty) {
      return null;
    }
    // kguanoluisa, Indice acotado para evitar RangeError al cambiar entre lecciones con distinto numero de fragmentos, sin nuevas variables, 2026-07-23
    final indice = vIndiceFragmento.clamp(0, vFragmentos.length - 1);
    return vFragmentos[indice];
  }

  bool get esUltimoFragmento => vIndiceFragmento >= vFragmentos.length - 1;
  bool get esPrimerFragmento => vIndiceFragmento == 0;

  Future<void> cargarLeccion({int leccionId = 1, int? perfilId}) async {
    vCargando = true;
    vError = null;
    // kguanoluisa, Reinicia indice y reproduccion al cargar otra leccion, sin nuevas variables, 2026-07-23
    vIndiceFragmento = 0;
    vReproduciendo = false;
    notifyListeners();

    try {
      vLeccion = await _leccionRepository.obtenerPorId(leccionId);
      if (vLeccion == null) {
        vError = 'Lección no encontrada';
        return;
      }

      // kguanoluisa, Carga fragmento en memoria para lecciones docente con texto en BD, sin nuevas variables, 2026-07-23
      if (vLeccion!.esLeccionDocente) {
        await _cargarFragmentosDesdeLeccion(vLeccion!);
      } else {
        final path = vLeccion!.contenidoMultimediaPath.isNotEmpty
            ? vLeccion!.contenidoMultimediaPath
            : null;
        await _cargarFragmentosDesdeAssets(path: path);
      }

      if (perfilId != null) {
        await _progresoRepository.guardar(
          Progreso(
            perfilId: perfilId,
            leccionId: leccionId,
            estado: EstadoProgreso.enCurso,
            fecha: DateTime.now(),
          ),
        );
      }
    } catch (error) {
      vError = error.toString();
    } finally {
      vCargando = false;
      notifyListeners();
    }
  }

  Future<void> cargarLeccionPorPath({
    required int leccionId,
    required String assetsPath,
    int? perfilId,
  }) async {
    vCargando = true;
    vError = null;
    // kguanoluisa, Reinicia indice y reproduccion al cargar otra leccion por path, sin nuevas variables, 2026-07-23
    vIndiceFragmento = 0;
    vReproduciendo = false;
    notifyListeners();

    try {
      vLeccion = await _leccionRepository.obtenerPorId(leccionId);
      if (vLeccion == null) {
        vError = 'Lección no encontrada';
        return;
      }

      if (vLeccion!.esLeccionDocente) {
        await _cargarFragmentosDesdeLeccion(vLeccion!);
      } else {
        await _cargarFragmentosDesdeAssets(path: assetsPath.isNotEmpty ? assetsPath : null);
      }

      if (perfilId != null && leccionId > 0) {
        await _progresoRepository.guardar(
          Progreso(
            perfilId: perfilId,
            leccionId: leccionId,
            estado: EstadoProgreso.enCurso,
            fecha: DateTime.now(),
          ),
        );
      }
    } catch (error) {
      vError = error.toString();
    } finally {
      vCargando = false;
      notifyListeners();
    }
  }

  Future<void> _cargarFragmentosDesdeLeccion(Leccion leccion) async {
    final subtitulo =
        '${leccion.historiaTexto}\n\n${leccion.versiculoReferencia}: ${leccion.versiculoTexto}';
    vFragmentos = [
      FragmentoNarrativo(
        id: 1,
        titulo: leccion.titulo,
        descripcion: leccion.historiaTexto,
        ilustracionAsset: '',
        videoLseAsset: '',
        audioAsset: '',
        duracionMs: 6000,
        pictogramas: [leccion.pictograma],
        textoSubtitulo: subtitulo,
      ),
    ];
    vIndiceFragmento = 0;
  }

  Future<void> _cargarFragmentosDesdeAssets({String? path}) async {
    final fragmentsPath = path ?? AppConstants.leccionBuenSamaritanoPath;
    final raw = await rootBundle.loadString(fragmentsPath);
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final fragmentosJson = data['fragmentos'] as List<dynamic>;

    final subtitulosPath = fragmentsPath.replaceAll('fragments.json', 'subtitles.json');
    final subtitulosRaw = await rootBundle.loadString(subtitulosPath);
    final subtitulosData = jsonDecode(subtitulosRaw) as Map<String, dynamic>;
    final subtitulos = subtitulosData['fragmentos'] as List<dynamic>;

    vFragmentos = fragmentosJson.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      final id = map['id'] as int;
      final subtitulo = subtitulos.cast<Map<String, dynamic>>().firstWhere(
            (frag) => frag['id'] == id,
            orElse: () => {'texto': map['descripcion'] ?? '', 'pictogramas': []},
          );
      map['texto'] = subtitulo['texto'];
      map['pictogramas'] = subtitulo['pictogramas'] ?? [];
      return FragmentoNarrativo.fromMap(map);
    }).toList();

    if (vFragmentos.isNotEmpty) {
      vIndiceFragmento = vIndiceFragmento.clamp(0, vFragmentos.length - 1);
    } else {
      vIndiceFragmento = 0;
    }
  }

  void alternarReproduccion() {
    vReproduciendo = !vReproduciendo;
    notifyListeners();
  }

  void fragmentoAnterior() {
    if (!esPrimerFragmento) {
      vIndiceFragmento--;
      notifyListeners();
    }
  }

  void fragmentoSiguiente() {
    if (!esUltimoFragmento) {
      vIndiceFragmento++;
      notifyListeners();
    }
  }

  Future<void> completarLeccion(int perfilId) async {
    if (vLeccion?.id == null) {
      return;
    }
    await _progresoRepository.guardar(
      Progreso(
        perfilId: perfilId,
        leccionId: vLeccion!.id!,
        estado: EstadoProgreso.completada,
        fecha: DateTime.now(),
      ),
    );
  }
}
