import 'package:flutter/material.dart';

/// Paleta de SeguroMina.
///
/// Los colores de marca vienen fijados por el brief. Los colores de nivel de
/// riesgo siguen la convención del Reglamento de Seguridad y Salud Ocupacional
/// en Minería (rojo / ámbar / verde para riesgo alto, medio y bajo).
///
/// Regla de accesibilidad que aplica a toda la app: **el color nunca es el
/// único portador de información**. Un nivel de riesgo siempre lleva su
/// etiqueta textual al lado, porque la deuteranopía y la protanopía son
/// frecuentes y esta app se usa para aprender a decidir sobre seguridad.
abstract final class AppColors {
  // --- Marca ---

  /// Azul confianza. Color primario de la app.
  static const Color primary = Color(0xFF2E5C8A);

  /// Variante clara del primario, para superficies en modo oscuro donde el
  /// azul original no alcanza contraste suficiente.
  static const Color primaryLight = Color(0xFF6B9BC9);

  /// Amarillo de seguridad minera.
  ///
  /// Contraste de 1.9:1 sobre blanco: **no cumple WCAG AA para texto**.
  /// Se usa solo como color de superficie, borde o acento gráfico, nunca
  /// como color de texto sobre fondo claro. El texto que va encima usa
  /// [onSecondary].
  static const Color secondary = Color(0xFFF4C430);
  static const Color onSecondary = Color(0xFF2C3E50);

  /// Verde de confirmación y éxito.
  static const Color accent = Color(0xFF27AE60);

  // --- Superficies ---

  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF5F7FA);
  static const Color backgroundDark = Color(0xFF1A1A1A);
  static const Color surfaceDark = Color(0xFF242424);

  // --- Texto ---

  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textPrimaryDark = Color(0xFFECEFF1);
  static const Color textSecondaryDark = Color(0xFFB0BEC5);

  // --- Niveles de riesgo (IPERC) ---

  /// Riesgo alto: corrección inmediata.
  static const Color riskHigh = Color(0xFFC0392B);

  /// Riesgo medio.
  ///
  /// Se usa naranja y no el amarillo de marca: el amarillo puro es
  /// ilegible sobre blanco y se confunde con el verde en protanopía.
  static const Color riskMedium = Color(0xFFE67E22);

  /// Riesgo bajo.
  static const Color riskLow = Color(0xFF27AE60);

  // --- Estados de la retroalimentación en escena ---

  /// Peligro identificado correctamente por el estudiante.
  static const Color feedbackCorrect = Color(0xFF27AE60);

  /// Peligro presente que el estudiante no vio.
  static const Color feedbackMissed = Color(0xFFE67E22);

  /// Marca del estudiante donde no había peligro (falso positivo).
  static const Color feedbackFalsePositive = Color(0xFF7F8C8D);

  // --- Error ---

  static const Color error = Color(0xFFC0392B);
}
