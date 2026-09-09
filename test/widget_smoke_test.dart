import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seguromina/app.dart';
import 'package:seguromina/core/flow/app_flow_controller.dart';
import 'package:seguromina/core/preferences/preferences_repository.dart';
import 'package:seguromina/features/splash/splash_screen.dart';

/// Arranca la app con preferencias en memoria.
///
/// El repositorio real usa canales de plataforma, que no existen en un test
/// de widget. Sobrescribirlo aqui es la razon por la que el provider no trae
/// implementacion por defecto.
Future<void> _pumpApp(
  WidgetTester tester, {
  Map<String, Object> seed = const <String, Object>{},
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        preferencesRepositoryProvider.overrideWithValue(
          InMemoryPreferencesRepository(seed),
        ),
      ],
      child: const SeguroMinaApp(),
    ),
  );
}

void main() {
  testWidgets('la app abre en el splash con la marca', (tester) async {
    await _pumpApp(tester);
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('SeguroMina'), findsOneWidget);
  });

  testWidgets('tras el splash, la primera vez muestra el onboarding',
      (tester) async {
    await _pumpApp(tester);
    await tester.pump();
    await tester.pump(SplashScreen.minimumDuration);
    await tester.pumpAndSettle();

    expect(find.text('Observa'), findsOneWidget);
    expect(find.text('Omitir'), findsOneWidget);
  });

  testWidgets('quien ya vio el onboarding entra al centro de entrenamiento',
      (tester) async {
    await _pumpApp(
      tester,
      seed: <String, Object>{AppFlowKeys.seenOnboarding: true},
    );
    await tester.pump();
    await tester.pump(SplashScreen.minimumDuration);
    await tester.pumpAndSettle();

    expect(
      find.text('Bienvenido al Centro de Entrenamiento Minero'),
      findsOneWidget,
    );
    // IndexedStack construye tambien la pestana de escenarios, que muestra
    // la misma ficha: por eso se esperan varias coincidencias.
    expect(find.text('Iniciar escenario'), findsWidgets);
  });

  testWidgets('el aviso academico es una tarjeta descartable, no un muro',
      (tester) async {
    await _pumpApp(
      tester,
      seed: <String, Object>{AppFlowKeys.seenOnboarding: true},
    );
    await tester.pump();
    await tester.pump(SplashScreen.minimumDuration);
    await tester.pumpAndSettle();

    // Convive con la mision: no ocupa la pantalla el solo.
    expect(find.textContaining('fines educativos'), findsOneWidget);
    expect(find.text('Iniciar escenario'), findsWidgets);

    await tester.tap(find.text('Entendido'));
    await tester.pumpAndSettle();

    expect(find.textContaining('fines educativos'), findsNothing);
    expect(find.text('Iniciar escenario'), findsWidgets);
  });
}
