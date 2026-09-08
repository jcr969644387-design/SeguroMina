import 'package:flutter_test/flutter_test.dart';
import 'package:seguromina/core/l10n/app_strings.dart';

void main() {
  const strings = AppStrings(
    <String, String>{
      'home.title': 'SeguroMina',
      'progress.summary': 'Identificaste {vistos} de {total} peligros',
    },
    'es',
  );

  test('devuelve el texto de una clave existente', () {
    expect(strings('home.title'), 'SeguroMina');
  });

  test('una clave faltante se hace visible en vez de fallar en silencio', () {
    expect(strings('no.existe'), '[no.existe]');
  });

  test('sustituye los marcadores de formato', () {
    expect(
      strings.format('progress.summary', <String, Object?>{
        'vistos': 4,
        'total': 7,
      }),
      'Identificaste 4 de 7 peligros',
    );
  });
}
