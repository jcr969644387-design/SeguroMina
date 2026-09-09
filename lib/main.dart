import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/preferences/preferences_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // La app se usa en una mano, con el telefono vertical. Las escenas se
  // disenan en proporcion vertical; permitir rotacion obligaria a mantener
  // dos composiciones de cada escena.
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  // Se resuelve antes de construir el arbol para que la primera pantalla ya
  // sepa si toca onboarding o home. Leerlo despues obligaria a mostrar un
  // estado de carga y luego saltar, que es justo el parpadeo que el splash
  // existe para evitar.
  final preferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: <Override>[
        preferencesRepositoryProvider.overrideWithValue(
          SharedPreferencesRepository(preferences),
        ),
      ],
      child: const SeguroMinaApp(),
    ),
  );
}
