import 'package:flutter/material.dart';
// kguanoluisa, Controlador de posicion y escala del overlay AR simulado, variables v_offset y v_escala, 2026-07-23
class ArOverlayController extends ChangeNotifier {
  Offset vOffset = Offset.zero;
  double vEscala = 1.0;

  void actualizarOffset(Offset delta) {
    vOffset += delta;
    notifyListeners();
  }

  void actualizarEscala(double delta) {
    vEscala = (vEscala + delta).clamp(0.5, 2.0);
    notifyListeners();
  }

  void actualizarEscalaDirecta(double escala) {
    vEscala = escala.clamp(0.5, 2.0);
    notifyListeners();
  }

  void reiniciar() {
    vOffset = Offset.zero;
    vEscala = 1.0;
    notifyListeners();
  }
}
