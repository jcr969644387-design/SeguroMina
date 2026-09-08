import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seguromina/core/theme/app_colors.dart';
import 'package:seguromina/core/theme/app_theme.dart';

/// Relación de contraste WCAG entre dos colores opacos.
double _contrast(Color a, Color b) {
  final l1 = a.computeLuminance();
  final l2 = b.computeLuminance();
  final lighter = l1 > l2 ? l1 : l2;
  final darker = l1 > l2 ? l2 : l1;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('Contraste de texto (WCAG AA = 4.5:1)', () {
    test('texto principal sobre fondo claro', () {
      expect(
        _contrast(AppColors.textPrimary, AppColors.backgroundLight),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('texto principal sobre fondo oscuro', () {
      expect(
        _contrast(AppColors.textPrimaryDark, AppColors.backgroundDark),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('texto blanco sobre el color primario', () {
      expect(
        _contrast(Colors.white, AppColors.primary),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('el texto sobre el amarillo de seguridad usa onSecondary', () {
      expect(
        _contrast(AppColors.onSecondary, AppColors.secondary),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('el amarillo de marca NO sirve como color de texto sobre blanco', () {
      // Deja constancia de por qué existe la regla: si alguien lo usa como
      // color de texto, este test documenta que estaba prohibido.
      expect(
        _contrast(AppColors.secondary, AppColors.backgroundLight),
        lessThan(4.5),
      );
    });
  });

  group('Niveles de riesgo', () {
    test('los tres niveles se distinguen por luminancia, no solo por tono', () {
      final high = AppColors.riskHigh.computeLuminance();
      final medium = AppColors.riskMedium.computeLuminance();
      final low = AppColors.riskLow.computeLuminance();

      expect((high - medium).abs(), greaterThan(0.05));
      expect((medium - low).abs(), greaterThan(0.05));
    });
  });

  group('Temas', () {
    test('el tema claro y el oscuro se construyen', () {
      expect(AppTheme.light.brightness, Brightness.light);
      expect(AppTheme.dark.brightness, Brightness.dark);
    });

    test('los botones respetan el objetivo tactil minimo de 48 dp', () {
      final style = AppTheme.light.filledButtonTheme.style;
      final size = style?.minimumSize?.resolve(<WidgetState>{});
      expect(size?.height, greaterThanOrEqualTo(48));
    });
  });
}
