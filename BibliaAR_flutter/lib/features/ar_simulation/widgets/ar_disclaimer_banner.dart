import 'package:biblia_ar_flutter/core/accessibility/biar_design_tokens.dart';
import 'package:biblia_ar_flutter/core/accessibility/biar_theme.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Banner de aviso que la vista AR es una simulacion sin marcadores, sin nuevas variables, 2026-07-23
class ArDisclaimerBanner extends StatelessWidget {
  const ArDisclaimerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: BiarSpacing.md,
        vertical: BiarSpacing.sm,
      ),
      color: BiarTheme.warningColor.withValues(alpha: 0.92),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.white),
          SizedBox(width: BiarSpacing.sm),
          Expanded(
            child: Text(
              'Vista previa AR — sin detección de marcadores',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
