import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seguromina/app.dart';

void main() {
  testWidgets('la app arranca y muestra el aviso de contenido en revision',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SeguroMinaApp()),
    );

    // Primer frame: los textos externos aun se estan cargando.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('SeguroMina'), findsOneWidget);
    expect(find.textContaining('no han sido validados'), findsOneWidget);
  });
}
