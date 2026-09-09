import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
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
///
/// La ventana se fija en 360x800 puntos, un telefono vertical corriente. El
/// tamano por defecto del entorno de pruebas es 800x600, apaisado: probar
/// ahi una app bloqueada en vertical mide una disposicion que nunca se va a
/// ejecutar, y esconde los desbordamientos que aparecen en una pantalla
/// estrecha.
Future<void> _pumpApp(
  WidgetTester tester, {
  Map<String, Object> seed = const <String, Object>{},
}) async {
  final strings = _realStrings();

  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

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
      find.text('Centro de Entrenamiento en Seguridad Minera'),
      findsOneWidget,
    );
    expect(find.text('Tu progreso'), findsOneWidget);

    // La barra inferior vive fuera del desplazamiento, asi que comprobarla
    // verifica que el contenedor de navegacion se monto sin depender de
    // cuanto contenido quepa en la primera pantalla. Se busca por tipo y no
    // por la etiqueta de una pestana, porque una etiqueta puede repetirse en
    // la pestana correspondiente y no quiero que el test dependa de si
    // `find` excluye o no las pestanas inactivas del IndexedStack.
    expect(find.byType(NavigationBar), findsOneWidget);

    // El ciclo empieza por aprender: la tarjeta destacada lleva a la
    // biblioteca, no directamente a un escenario. Vive mas abajo, asi que se
    // desplaza en vez de dar por hecho que cabe: donde caiga exactamente es
    // una cuestion de maquetacion, no algo que este test deba fijar.
    await tester.drag(find.byType(ListView).first, const Offset(0, -400));
    await tester.pump();
    // Margen acotado para que termine cualquier inercia del gesto.
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Continuar'), findsOneWidget);
  });

  testWidgets('el aviso academico es una tarjeta descartable, no un muro',
      (tester) async {
    await _pumpApp(
      tester,
      seed: <String, Object>{AppFlowKeys.seenOnboarding: true},
    );
    await _skipSplash(tester);

    // Dos cosas a la vez, y las dos importan. Que el aviso convive con el
    // resto del centro de entrenamiento en vez de ocupar la pantalla entera,
    // y que se ve sin desplazar: `find` ignora lo que queda fuera del
    // viewport, asi que si alguien lo empuja hacia el final de la lista este
    // test falla. Es lo que se quiere: un aviso que hay que ir a buscar no
    // cumple su funcion.
    expect(find.textContaining('fines educativos'), findsOneWidget);
    expect(find.text('Tu progreso'), findsOneWidget);

    await tester.ensureVisible(find.text('Entendido'));
    await tester.pump();
    await tester.tap(find.text('Entendido'));
    await tester.pump();

    // Solo se comprueba la desaparicion de la tarjeta. Volver a buscar la
    // ficha de mision no serviria: `ensureVisible` puede haber desplazado la
    // lista, y `find` ignora lo que quedo fuera del viewport.
    expect(find.textContaining('fines educativos'), findsNothing);
    expect(find.text('Entendido'), findsNothing);
  });
}
