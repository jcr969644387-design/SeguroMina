import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // La app se usa en una mano, con el teléfono vertical. Las escenas se
  // diseñan en proporción vertical; permitir rotación obligaría a mantener
  // dos composiciones de cada escena.
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    const ProviderScope(
      child: SeguroMinaApp(),
    ),
  );
}
