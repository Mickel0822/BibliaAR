import 'package:flutter/material.dart';

// kguanoluisa, Reproductor LSE adaptable (flotante o banner en línea), variables v_expandido y vInline, 2026-07-29
class FloatingLsePlayer extends StatefulWidget {
  const FloatingLsePlayer({
    super.key,
    required this.vTitulo,
    required this.vDescripcion,
    this.vVideoAsset = '',
    this.vInline = false,
  });

  final String vTitulo;
  final String vDescripcion;
  final String vVideoAsset;
  final bool vInline;

  @override
  State<FloatingLsePlayer> createState() => _FloatingLsePlayerState();
}

class _FloatingLsePlayerState extends State<FloatingLsePlayer> {
  bool vExpandido = false;

  @override
  Widget build(BuildContext context) {
    if (widget.vInline) {
      // Vista en línea (adaptada al ancho de pantalla)
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5A623), // Color amarillo/naranja de la captura del usuario
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              blurRadius: 4,
              offset: Offset(0, 2),
              color: Colors.black12,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.sign_language,
                size: 44,
                color: Color(0xFF1E3A8A), // Azul marino de alto contraste para accesibilidad
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.vTitulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.vDescripcion,
                      style: const TextStyle(
                        color: Color(0xFF374151),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Vista flotante por defecto
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
