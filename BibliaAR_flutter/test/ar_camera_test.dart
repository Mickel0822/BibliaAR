import 'package:biblia_ar_flutter/core/platform/camera_permission_service.dart';
import 'package:biblia_ar_flutter/features/ar_simulation/ar_overlay_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CameraPermissionService expone solicitud de permiso', () {
    final service = CameraPermissionService();
    expect(service.solicitarPermisoCamara, isA<Function>());
  });

  test('ArOverlayController limita escala entre 0.5 y 2.0', () {
    final controller = ArOverlayController();
    controller.actualizarEscalaDirecta(3.0);
    expect(controller.vEscala, 2.0);

    controller.actualizarEscalaDirecta(0.1);
    expect(controller.vEscala, 0.5);

    controller.reiniciar();
    expect(controller.vOffset, const Offset(0, 0));
    expect(controller.vEscala, 1.0);
  });
}
