import 'package:biblia_ar_flutter/data/models/certificado_conadis.dart';
import 'package:biblia_ar_flutter/data/models/configuracion_sensorial.dart';
import 'package:biblia_ar_flutter/data/models/perfil.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/conadis_repository.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/configuracion_repository.dart';
import 'package:biblia_ar_flutter/data/repositories/interfaces/perfil_repository.dart';
import 'package:biblia_ar_flutter/features/egov/conadis/conadis_consulta_screen.dart';
import 'package:biblia_ar_flutter/features/egov/conadis/conadis_provider.dart';
import 'package:biblia_ar_flutter/features/profiles/perfil_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class FakeConadisRepository implements ConadisRepository {
  @override
  Future<CertificadoConadis?> consultarPorNumero(String numeroCertificado) async => null;

  @override
  Future<void> guardarConsulta({
    required int perfilId,
    required CertificadoConadis certificado,
  }) async {}
}

class FakePerfilRepository implements PerfilRepository {
  @override
  Future<Perfil> crear(Perfil perfil) async => perfil;

  @override
  Future<void> eliminar(int id) async {}

  @override
  Future<Perfil?> obtenerPorId(int id) async => null;

  @override
  Future<List<Perfil>> obtenerPorTipo(String tipoUsuario) async => [];

  @override
  Future<List<Perfil>> obtenerTodos() async => [];

  @override
  Future<int?> obtenerPerfilActivoId() async => null;

  @override
  Future<void> guardarPerfilActivoId(int perfilId) async {}

  @override
  Future<void> limpiarPerfilActivo() async {}
}

class FakeConfiguracionRepository implements ConfiguracionRepository {
  @override
  Future<ConfiguracionSensorial> crearPorDefecto(int perfilId) async =>
      ConfiguracionSensorial(perfilId: perfilId);

  @override
  Future<ConfiguracionSensorial?> obtenerPorPerfil(int perfilId) async => null;

  @override
  Future<void> guardar(ConfiguracionSensorial configuracion) async {}
}

Widget _buildTestApp(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => PerfilProvider(
          perfilRepository: FakePerfilRepository(),
          configuracionRepository: FakeConfiguracionRepository(),
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => ConadisProvider(conadisRepository: FakeConadisRepository()),
      ),
      ChangeNotifierProvider(
        create: (_) => ConfiguracionProvider(configuracionRepository: FakeConfiguracionRepository()),
      ),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  testWidgets('ConadisConsultaScreen muestra campo de certificado y boton consultar', (tester) async {
    await tester.pumpWidget(_buildTestApp(const ConadisConsultaScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Verificar certificado CONADIS'), findsOneWidget);
    expect(find.text('Número de certificado'), findsWidgets);
    expect(find.text('Consultar'), findsOneWidget);
    expect(find.textContaining('simulación educativa'), findsNothing);
    expect(find.text('Modo de consulta'), findsNothing);
  });

  testWidgets('boton Consultar deshabilitado con formato invalido', (tester) async {
    await tester.pumpWidget(_buildTestApp(const ConadisConsultaScreen()));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'INVALIDO');
    await tester.pump();

    final boton = tester.widget<ElevatedButton>(find.byType(ElevatedButton).first);
    expect(boton.onPressed, isNull);
  });
}
