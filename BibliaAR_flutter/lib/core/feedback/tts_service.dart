import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

// kguanoluisa, Servicio centralizado de Text-To-Speech para narracion accesible en lecciones y pictogramas, sin nuevas variables, 2026-07-29
class TtsService {
  TtsService._internal() {
    _init();
  }

  static final TtsService instance = TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _inicializado = false;

  Future<void> _init() async {
    try {
      await _flutterTts.setLanguage("es-ES");
      _inicializado = true;
    } catch (e) {
      debugPrint("Error inicializando TTS: $e");
    }
  }

  Future<void> speak(String text, {double volume = 1.0, double rate = 1.0}) async {
    if (!_inicializado) {
      await _init();
    }
    try {
      double ttsRate = rate * 0.5;
      await _flutterTts.setVolume(volume.clamp(0.0, 1.0));
      await _flutterTts.setSpeechRate(ttsRate.clamp(0.0, 1.0));
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint("Error en speak de TTS: $e");
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint("Error deteniendo TTS: $e");
    }
  }
}
