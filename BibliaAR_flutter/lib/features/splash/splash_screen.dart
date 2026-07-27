import 'package:biblia_ar_flutter/core/constants/app_constants.dart';
import 'package:biblia_ar_flutter/core/routing/route_names.dart';
import 'package:biblia_ar_flutter/core/routing/session_navigation.dart';
import 'package:biblia_ar_flutter/features/auth/auth_provider.dart';
import 'package:flutter/material.dart';import 'package:provider/provider.dart';

// kguanoluisa, Pantalla de bienvenida con redireccion a login, perfiles o home segun sesion activa, sin nuevas variables, 2026-07-23
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  Future<void> _inicializar() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.cargarSesion();
    if (!mounted) {
      return;
    }

    if (!authProvider.vAutenticado) {
      Navigator.pushReplacementNamed(context, RouteNames.login);
      return;
    }

    await SessionNavigation.irAlHomeTrasLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
