import 'package:flutter/material.dart';

// kguanoluisa, Reproductor LSE flotante expandible al 50% del ancho de pantalla, variables v_expandido y v_titulo, 2026-07-23
class FloatingLsePlayer extends StatefulWidget {
  const FloatingLsePlayer({
    super.key,
    required this.vTitulo,
    required this.vDescripcion,
    this.vVideoAsset = '',
  });

  final String vTitulo;
  final String vDescripcion;
  final String vVideoAsset;

  @override
  State<FloatingLsePlayer> createState() => _FloatingLsePlayerState();
}

class _FloatingLsePlayerState extends State<FloatingLsePlayer> {
  bool vExpandido = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final width = vExpandido ? screenWidth * 0.5 : screenWidth * 0.25;

    return Align(
      alignment: Alignment.topRight,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: width,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              offset: Offset(0, 2),
              color: Colors.black26,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              dense: true,
              title: Text(
                'LSE',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              trailing: IconButton(
                icon: Icon(vExpandido ? Icons.compress : Icons.expand),
                onPressed: () => setState(() => vExpandido = !vExpandido),
                tooltip: vExpandido ? 'Reducir ventana LSE' : 'Ampliar ventana LSE',
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: [
                  Icon(
                    Icons.sign_language,
                    size: vExpandido ? 64 : 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.vTitulo,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (vExpandido) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.vDescripcion,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
