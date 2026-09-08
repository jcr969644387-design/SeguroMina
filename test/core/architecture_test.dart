import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Prueba de arquitectura.
///
/// La capa de dominio contiene el motor de evaluacion de riesgo. Debe poder
/// auditarse y ejecutarse sin Flutter, para que un especialista pueda revisar
/// las reglas y para que los tests corran sin emulador. Este test falla si
/// alguien importa Flutter ahi.
void main() {
  test('lib/domain no depende de Flutter', () {
    final dir = Directory('lib/domain');
    if (!dir.existsSync()) return;

    final offenders = <String>[];
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final content = entity.readAsStringSync();
      if (content.contains('package:flutter/') ||
          content.contains('package:flutter_riverpod/')) {
        offenders.add(entity.path);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'La capa de dominio debe ser Dart puro. Archivos con import de '
          'Flutter: ${offenders.join(", ")}',
    );
  });
}
