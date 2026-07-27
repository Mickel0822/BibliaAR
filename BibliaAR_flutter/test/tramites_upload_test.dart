import 'package:biblia_ar_flutter/features/egov/tramites_upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('TramitesUploadScreen muestra selector de documentos al iniciar', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TramitesUploadScreen(),
      ),
    );

    await tester.pump();

    expect(find.text('Trámites accesibles'), findsOneWidget);
    expect(find.text('Seleccionar documento'), findsOneWidget);
    expect(find.text('Sube cualquier documento para tu trámite municipal'), findsOneWidget);
  });
}
