import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tutor_app/main.dart';

void main() {
  testWidgets('Prueba de carga inicial de TutorMatch', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TutorMatchApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
