import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seguromina/app.dart';
import 'package:seguromina/core/flow/app_flow_controller.dart';
import 'package:seguromina/core/l10n/app_strings.dart';
import 'package:seguromina/core/preferences/preferences_repository.dart';
import 'package:seguromina/features/splash/splash_screen.dart';

/// Textos reales, leidos del disco en vez de del bundle de assets.
///
/// Cargarlos por `rootBundle` deja el provider en estado de carga durante
/// unos frames, y mientras tanto las pantallas muestran un
/// `CircularProgressIndicator`, que programa frames sin parar: con el en
/// pantalla, `pumpAndSettle` no puede asentarse nunca. Leer el mismo archivo
/// de forma sincrona mantiene las aserciones sobre los textos de verdad y
/// quita esa indeterminacion. Que el archivo se pueda leer por el bundle lo
/// cubre `app_strings_test.dart`.
AppStrings _realStrings() {
  final raw = File('assets/i18n/es.json').readAsStringSync();
  final decoded = jsonDecode(raw) as Map<String, dynamic>;
  return AppStrings(
    decoded.map((key, value) => MapEntry(key, value.toString())),
    'es',
  );
}

/// Arranca la app con preferencias en memoria y los textos ya resueltos.
///
/// El repositorio real usa canales de plataforma, que no existen en un test
/// de widget. Sobrescribirlo aqui es la razon por la que el provider no trae
/// implementacion por defecto.
Future<void> _pumpApp(
  WidgetTester tester, {
  Map<String, Object> seed = const <String, Object>{},
}) async {
  final strings = _realStrings();

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        preferencesRepositoryProvider.overrideWithValue(
          InMemoryPreferencesRepository(seed),
        ),
        appStringsProvider.overrideWith((ref) => strings),
      ],
      child: const SeguroMinaApp(),
    ),
  );
}

/// Avanza el splash y la transicion posterior con pausas acotadas.
///
/// No se usa `pumpAndSettle`: basta con que pase el tiempo del splash mas el
/// de la transicion, y asi el test no depende de que no quede ninguna
/// animacion viva en el arbol.
Future<void> _skipSplash(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(SplashScreen.minimumDuration);
  await tester.pump(const Duration(milliseconds: 400));
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
    await _skipSplash(tester);

    expect(find.text('Observa'), findsOneWidget);
    expect(find.text('Omitir'), findsOneWidget);
  });

  testWidgets('quien ya vio el onboarding entra al centro de entrenamiento',
      (tester) async {
    await _pumpApp(
      tester,
      seed: <String, Object>{AppFlowKeys.seenOnboarding: true},
    );
    await _skipSplash(tester);

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
    await _skipSplash(tester);

    // Convive con la mision: no ocupa la pantalla el solo.
    expect(find.textContaining('fines educativos'), findsOneWidget);
    expect(find.text('Iniciar escenario'), findsWidgets);

    await tester.ensureVisible(find.text('Entendido'));
    await tester.pump();
    await tester.tap(find.text('Entendido'));
    await tester.pump();

    expect(find.textContaining('fines educativos'), findsNothing);
    expect(find.text('Iniciar escenario'), findsWidgets);
  });
}
