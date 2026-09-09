import 'risk_level.dart';

/// Zona rectangular de la escena, en coordenadas relativas (0..1).
///
/// Relativas y no en pixeles: la misma escena se renderiza en pantallas de
/// distinto tamano y el area sensible debe seguir cayendo sobre el peligro.
class HazardArea {
  const HazardArea({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;

  double get centerX => left + width / 2;
  double get centerY => top + height / 2;

  bool contains(double x, double y) {
    return x >= left && x <= left + width && y >= top && y <= top + height;
  }
}

/// Un peligro observable dentro de una escena de entrenamiento.
///
/// Lleva el texto y no claves de traduccion: es material didactico, crece y
/// se corrige en `assets/content/` sin recompilar, igual que la biblioteca.
class Hazard {
  const Hazard({
    required this.id,
    required this.label,
    required this.explanation,
    required this.control,
    required this.area,
    required this.severity,
  });

  final String id;
  final String label;
  final String explanation;

  /// Control recomendado. Es la parte que convierte la identificacion en
  /// decision: ver el peligro no basta, hay que saber que se hace con el.
  final String control;

  final HazardArea area;
  final RiskLevel severity;
}
