import 'package:flutter/material.dart';

/// Escala tipográfica de SeguroMina.
///
/// Todos los tamaños están en unidades lógicas y se escalan con el ajuste de
/// tamaño de fuente del sistema. Ninguna pantalla debe usar tamaños fijos
/// fuera de esta escala: el escalado de texto es un requisito de
/// accesibilidad del proyecto, no una preferencia.
abstract final class AppTypography {
  /// Título de pantalla. Uso escaso: una vez por pantalla como máximo.
  static const TextStyle display = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
  );

  static const TextStyle heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  /// Texto corrido. El briefing de escenario y el debrief lo usan.
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  /// Etiquetas de botón y de control.
  static const TextStyle label = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  /// Metadatos: referencia normativa, versión de contenido, marca de tiempo.
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );
}

/// Escala de espaciado en múltiplos de 4.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Altura mínima de cualquier objetivo táctil.
  ///
  /// 48 dp es el mínimo de Material y de WCAG. En la pantalla de inspección
  /// los marcadores de peligro deben respetarlo aunque el punto visible sea
  /// más pequeño.
  static const double minTouchTarget = 48;

  /// Radio de esquina estándar.
  static const double radius = 12;
}
