import 'package:biblia_ar_flutter/shared/widgets/lesson_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LessonCard muestra titulo y versiculo', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LessonCard(
            vTitulo: 'El Buen Samaritano',
            vVersiculoReferencia: 'Lucas 10:25-37',
            vIcono: Icons.auto_stories,
            vEstadoLabel: 'Nueva',
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('El Buen Samaritano'), findsOneWidget);
    expect(find.text('Lucas 10:25-37'), findsOneWidget);
    expect(find.text('Nueva'), findsOneWidget);
  });
}
