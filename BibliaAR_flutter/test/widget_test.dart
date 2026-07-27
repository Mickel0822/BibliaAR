import 'package:biblia_ar_flutter/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  testWidgets('BIAR app muestra splash inicial', (WidgetTester tester) async {
    await tester.pumpWidget(const BiarApp());
    await tester.pump();

    expect(find.text('BIAR'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
