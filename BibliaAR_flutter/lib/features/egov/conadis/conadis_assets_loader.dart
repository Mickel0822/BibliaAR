import 'dart:convert';

import 'package:biblia_ar_flutter/data/models/fragmento_narrativo.dart';
import 'package:flutter/services.dart';

// kguanoluisa, Cargador de fragmentos narrativos desde assets JSON para flujo CONADIS, sin nuevas variables, 2026-07-29
class ConadisAssetsLoader {
  static Future<List<FragmentoNarrativo>> cargarFragmentos(String fragmentsPath) async {
    final raw = await rootBundle.loadString(fragmentsPath);
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final fragmentosJson = data['fragmentos'] as List<dynamic>;

    final subtitulosPath = fragmentsPath.replaceAll('fragments.json', 'subtitles.json');
    final subtitulosRaw = await rootBundle.loadString(subtitulosPath);
    final subtitulosData = jsonDecode(subtitulosRaw) as Map<String, dynamic>;
    final subtitulos = subtitulosData['fragmentos'] as List<dynamic>;

    return fragmentosJson.map((item) {
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
  }
}
