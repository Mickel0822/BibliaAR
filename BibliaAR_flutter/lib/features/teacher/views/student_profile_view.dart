import 'package:biblia_ar_flutter/data/models/perfil.dart';
import 'package:flutter/material.dart';

// kguanoluisa, Estructura base de vista individual de estudiante BIAR-52/53, variables v_perfil, 2026-07-14
class StudentProfileView extends StatelessWidget {
  const StudentProfileView({super.key, required this.vPerfil});

  final Perfil vPerfil;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(vPerfil.nombre),
      subtitle: const Text('Perfil de estudiante'),
    );
  }
}
