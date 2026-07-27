import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/core/platform/camera_permission_service.dart';
import 'package:biblia_ar_flutter/features/ar_simulation/ar_overlay_controller.dart';
import 'package:biblia_ar_flutter/features/ar_simulation/ar_preview_args.dart';
import 'package:biblia_ar_flutter/features/ar_simulation/widgets/ar_disclaimer_banner.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_button.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_error_view.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_loading_view.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// kguanoluisa, Pantalla de simulacion AR con camara en vivo y overlay draggable/scalable, variables v_cameraController y v_overlayController, 2026-07-23
class ArPreviewScreen extends StatefulWidget {
  const ArPreviewScreen({super.key, required this.vArgs});

  final ArPreviewArgs vArgs;

  @override
  State<ArPreviewScreen> createState() => _ArPreviewScreenState();
}

class _ArPreviewScreenState extends State<ArPreviewScreen> {
  final CameraPermissionService _permissionService = CameraPermissionService();
  final ArOverlayController _overlayController = ArOverlayController();
  CameraController? vCameraController;
  bool vPermisoDenegado = false;
  bool vInicializando = true;
  String? vError;
  double _escalaBase = 1.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializarCamara());
  }

  Future<void> _inicializarCamara() async {
    setState(() {
      vInicializando = true;
      vError = null;
      vPermisoDenegado = false;
    });

    final permitido = await _permissionService.solicitarPermisoCamara();
    if (!permitido) {
      if (!mounted) return;
      setState(() {
        vPermisoDenegado = true;
        vInicializando = false;
      });
      return;
    }

    try {
      final cameras = await availableCameras();
      final trasera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        trasera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        vCameraController = controller;
        vInicializando = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        vError = error.toString();
        vInicializando = false;
      });
    }
  }

  @override
  void dispose() {
    vCameraController?.dispose();
    _overlayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _overlayController,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('Vista previa AR — ${widget.vArgs.vTitulo}'),
          backgroundColor: Colors.black87,
        ),
        body: Column(
          children: [
            const ArDisclaimerBanner(),
            Expanded(child: _buildBody()),
            Padding(
              padding: const EdgeInsets.all(BiarSpacing.md),
              child: BiarButton(
                label: 'Cerrar vista previa',
                icon: Icons.close,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (vInicializando) {
      return const BiarLoadingView(vMensaje: 'Iniciando cámara...');
    }
    if (vPermisoDenegado) {
      return BiarErrorView(
        vMensaje: 'Se necesita permiso de cámara para la vista previa AR.',
        onReintentar: _inicializarCamara,
      );
    }
    if (vError != null) {
      return BiarErrorView(vMensaje: vError!, onReintentar: _inicializarCamara);
    }
    if (vCameraController == null || !vCameraController!.value.isInitialized) {
      return const BiarLoadingView();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(vCameraController!),
            Center(
              child: Consumer<ArOverlayController>(
                builder: (context, controller, _) {
                  return Transform.translate(
                    offset: controller.vOffset,
                    child: Transform.scale(
                      scale: controller.vEscala,
                      child: GestureDetector(
                        // kguanoluisa, Gesto unificado con onScale para arrastre y pellizco sin mezclar onPan, sin nuevas variables, 2026-07-23
                        onScaleStart: (_) => _escalaBase = controller.vEscala,
                        onScaleUpdate: (details) {
                          controller.actualizarOffset(details.focalPointDelta);
                          controller.actualizarEscalaDirecta(_escalaBase * details.scale);
                        },
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(BiarRadius.lg),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(BiarRadius.lg),
                            child: Image.asset(
                              widget.vArgs.vOverlayAsset,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => ColoredBox(
                                color: Colors.white.withValues(alpha: 0.2),
                                child: const Icon(
                                  Icons.person,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
