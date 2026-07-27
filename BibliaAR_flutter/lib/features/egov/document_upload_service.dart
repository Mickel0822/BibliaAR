import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// kguanoluisa, Servicio para guardar documentos de tramites en almacenamiento local de la app, variable v_carpetaTramites, 2026-07-23
class DocumentUploadService {
  static const String vCarpetaTramites = 'tramites';

  Future<Directory> obtenerCarpetaTramites() async {
    final dir = await getApplicationDocumentsDirectory();
    final carpeta = Directory(p.join(dir.path, vCarpetaTramites));
    if (!await carpeta.exists()) {
      await carpeta.create(recursive: true);
    }
    return carpeta;
  }

  Future<List<File>> listarDocumentosGuardados() async {
    final carpeta = await obtenerCarpetaTramites();
    if (!await carpeta.exists()) {
      return [];
    }

    final entidades = await carpeta.list().toList();
    final archivos = entidades.whereType<File>().toList();

    archivos.sort((a, b) {
      final modA = a.statSync().modified;
      final modB = b.statSync().modified;
      return modB.compareTo(modA);
    });

    return archivos;
  }

  Future<String> guardarDocumento({
    required String vRutaOrigen,
    required String vNombreArchivo,
  }) async {
    final carpeta = await obtenerCarpetaTramites();
    final nombreSeguro = p.basename(vNombreArchivo);
    final destino = p.join(carpeta.path, nombreSeguro);

    if (await File(destino).exists()) {
      final extension = p.extension(nombreSeguro);
      final base = p.basenameWithoutExtension(nombreSeguro);
      final marca = DateTime.now().millisecondsSinceEpoch;
      final destinoUnico = p.join(carpeta.path, '${base}_$marca$extension');
      await File(vRutaOrigen).copy(destinoUnico);
      return destinoUnico;
    }

    await File(vRutaOrigen).copy(destino);
    return destino;
  }

  Future<String> guardarBytes({
    required List<int> vBytes,
    required String vNombreArchivo,
  }) async {
    final carpeta = await obtenerCarpetaTramites();
    final nombreSeguro = p.basename(vNombreArchivo);
    final destino = p.join(carpeta.path, nombreSeguro);

    if (await File(destino).exists()) {
      final extension = p.extension(nombreSeguro);
      final base = p.basenameWithoutExtension(nombreSeguro);
      final marca = DateTime.now().millisecondsSinceEpoch;
      final destinoUnico = p.join(carpeta.path, '${base}_$marca$extension');
      await File(destinoUnico).writeAsBytes(vBytes);
      return destinoUnico;
    }

    await File(destino).writeAsBytes(vBytes);
    return destino;
  }
}
