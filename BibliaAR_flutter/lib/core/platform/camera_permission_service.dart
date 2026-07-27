import 'package:permission_handler/permission_handler.dart';

// kguanoluisa, Servicio para solicitar permiso de camara en tiempo de ejecucion, sin nuevas variables, 2026-07-23
class CameraPermissionService {
  Future<bool> solicitarPermisoCamara() async {
    final estado = await Permission.camera.status;
    if (estado.isGranted) {
      return true;
    }
    final resultado = await Permission.camera.request();
    return resultado.isGranted;
  }

  Future<void> abrirAjustes() => openAppSettings();
}
