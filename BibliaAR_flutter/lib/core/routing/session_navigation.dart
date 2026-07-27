import 'package:biblia_ar_flutter/core/routing/route_names.dart';
import 'package:biblia_ar_flutter/features/auth/auth_provider.dart';
import 'package:biblia_ar_flutter/features/profiles/perfil_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// kguanoluisa, Helper para resolver perfil automatico y navegar al home tras login, sin nuevas variables, 2026-07-23
class SessionNavigation {
  static Future<void> irAlHomeTrasLogin(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    if (auth.vRol == null || auth.vUsuario == null) {
      Navigator.pushReplacementNamed(context, RouteNames.login);
      return;
    }

    final perfil = await context.read<PerfilProvider>().resolverPerfilDesdeSesion(
          vTipoUsuario: auth.vRol!,
        );
    if (!context.mounted) {
      return;
    }
    await context.read<ConfiguracionProvider>().cargar(perfil.id!);
    if (!context.mounted) {
      return;
    }
    Navigator.pushReplacementNamed(context, RouteNames.home);
  }
}
