import 'dart:convert';
import 'dart:io';

import 'package:biblia_ar_flutter/spike/persistencia_local/storage/local_storage_adapter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Implementación del spike simulando Hive con almacenamiento en archivo JSON.
///
/// El spike compara el modelo key-value de Hive frente al relacional de sqflite.
/// Se usa JSON en disco para evitar dependencias adicionales en este entorno de evaluación.
class HiveStorageAdapter implements LocalStorageAdapter {
  HiveStorageAdapter({this.boxName = 'spike_hive_box'});

  final String boxName;
  File? _boxFile;
  final List<Map<String, dynamic>> _records = [];

  @override
  String get name => 'hive';

  @override
  Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    _boxFile = File(p.join(dir.path, '$boxName.json'));
    if (await _boxFile!.exists()) {
      final content = await _boxFile!.readAsString();
      if (content.isNotEmpty) {
        final decoded = jsonDecode(content) as List<dynamic>;
        _records
          ..clear()
          ..addAll(decoded.cast<Map<String, dynamic>>());
      }
    }
  }

  Future<void> _persist() async {
    await _boxFile!.writeAsString(jsonEncode(_records));
  }

  @override
  Future<void> writeBatch(int count) async {
    final now = DateTime.now().toIso8601String();
    for (var i = 0; i < count; i++) {
      _records.add({
        'id': _records.length + 1,
        'perfil_id': 1,
        'actividad_id': i + 1,
        'resultado': 'correcto',
        'fecha': now,
      });
    }
    await _persist();
  }

  @override
  Future<List<Map<String, dynamic>>> readAll() async {
    return List<Map<String, dynamic>>.from(_records);
  }

  @override
  Future<void> clear() async {
    _records.clear();
    await _persist();
  }

  @override
  Future<void> dispose() async {
    _records.clear();
    _boxFile = null;
  }
}
