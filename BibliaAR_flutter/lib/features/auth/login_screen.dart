import 'package:biblia_ar_flutter/core/constants/app_constants.dart';
import 'package:biblia_ar_flutter/core/constants/auth_credentials.dart';
import 'package:biblia_ar_flutter/core/routing/session_navigation.dart';
import 'package:biblia_ar_flutter/features/auth/auth_provider.dart';
import 'package:biblia_ar_flutter/shared/widgets/biar_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// kguanoluisa, Pantalla de login inicial con usuario y contraseña para roles nino y docente, variables v_usuarioController y v_claveController, 2026-07-23
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController vUsuarioController = TextEditingController();
  final TextEditingController vClaveController = TextEditingController();
  bool vMostrarClave = false;
  bool vEnviando = false;

  @override
  void dispose() {
    vUsuarioController.dispose();
    vClaveController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    final usuario = vUsuarioController.text.trim();
    final clave = vClaveController.text;

    if (usuario.isEmpty || clave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa usuario y contraseña')),
      );
      return;
    }

    setState(() => vEnviando = true);
    final auth = context.read<AuthProvider>();
    final exito = await auth.iniciarSesion(usuario: usuario, clave: clave);
    if (!mounted) {
      return;
    }
    setState(() => vEnviando = false);

    if (!exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.vError ?? 'No se pudo iniciar sesión')),
      );
      return;
    }

    await SessionNavigation.irAlHomeTrasLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Icon(
                Icons.menu_book,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                AppConstants.appName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Inicia sesión para continuar',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: vUsuarioController,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                autocorrect: false,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: vClaveController,
                obscureText: !vMostrarClave,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      vMostrarClave ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => vMostrarClave = !vMostrarClave),
                  ),
                ),
                onSubmitted: (_) => _iniciarSesion(),
              ),
              const SizedBox(height: 24),
              BiarButton(
                label: vEnviando ? 'Ingresando...' : 'Ingresar',
                icon: Icons.login,
                onPressed: vEnviando ? null : _iniciarSesion,
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Credenciales de prueba',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 18,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _CredencialItem(
                        rol: 'Niño',
                        usuario: AuthCredentials.vUsuarioNino,
                        clave: AuthCredentials.vClaveNino,
                      ),
                      const Divider(height: 24),
                      _CredencialItem(
                        rol: 'Docente',
                        usuario: AuthCredentials.vUsuarioDocente,
                        clave: AuthCredentials.vClaveDocente,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CredencialItem extends StatelessWidget {
  const _CredencialItem({
    required this.rol,
    required this.usuario,
    required this.clave,
  });

  final String rol;
  final String usuario;
  final String clave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rol, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        Text('Usuario: $usuario'),
        Text('Contraseña: $clave'),
      ],
    );
  }
}
