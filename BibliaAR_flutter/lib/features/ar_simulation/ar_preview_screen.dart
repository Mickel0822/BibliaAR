import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/core/feedback/tts_service.dart';
import 'package:biblia_ar_flutter/core/platform/camera_permission_service.dart';
import 'package:biblia_ar_flutter/features/ar_simulation/ar_overlay_controller.dart';
import 'package:biblia_ar_flutter/features/ar_simulation/ar_preview_args.dart';
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

class _ArPreviewScreenState extends State<ArPreviewScreen> with SingleTickerProviderStateMixin {
  final CameraPermissionService _permissionService = CameraPermissionService();
  final ArOverlayController _overlayController = ArOverlayController();
  CameraController? vCameraController;
  bool vPermisoDenegado = false;
  bool vInicializando = true;
  String? vError;
  double _escalaBase = 1.0;
  late final AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    // Animación lenta y continua de vaivén para el holograma AR
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    
    // Narrar el texto de la escena al abrir la vista previa
    if (widget.vArgs.vNarration.isNotEmpty) {
      TtsService.instance.speak(widget.vArgs.vNarration);
    }
    
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
    TtsService.instance.stop(); // Detener narración al salir de la pantalla
    vCameraController?.dispose();
    _overlayController.dispose();
    _hoverController.dispose();
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
                        child: SizedBox(
                          width: 260,
                          height: 260,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Pedestal holográfico brillante de AR en el suelo/base
                              Positioned(
                                bottom: 15,
                                child: AnimatedBuilder(
                                  animation: _hoverController,
                                  builder: (context, child) {
                                    final glowSpread = _hoverController.value * 4.0;
                                    final blurRadius = 8.0 + _hoverController.value * 6.0;
                                    return Container(
                                      width: 160,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(Radius.elliptical(80, 12)),
                                        border: Border.all(
                                          color: Colors.cyanAccent.withValues(alpha: 0.9),
                                          width: 2.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.cyanAccent.withValues(alpha: 0.65),
                                            blurRadius: blurRadius,
                                            spreadRadius: 1.5 + glowSpread,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // Personaje o escena en realidad aumentada sin fondo cuadrado
                              Positioned.fill(
                                bottom: 30,
                                child: AnimatedBuilder(
                                  animation: _hoverController,
                                  builder: (context, child) {
                                    // Vaivén vertical de 0 a 14 píxeles para simular flotabilidad
                                    final floatOffset = _hoverController.value * -14.0;
                                    return Transform.translate(
                                      offset: Offset(0, floatOffset),
                                      child: Image.asset(
                                        widget.vArgs.vOverlayAsset,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, _, _) => const Icon(
                                          Icons.person,
                                          size: 140,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
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
