import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/training/hazard.dart';
import '../../../domain/training/mission_scoring.dart';
import '../../../domain/training/scenario.dart';

/// Corte tecnico de la labor.
///
/// Es una lamina de ingenieria, no una ilustracion: macizo con trama, vano
/// excavado, piso, y sobre el una biblioteca de simbolos normalizados. Todos
/// los elementos se dibujan con la misma tinta y el mismo grosor, de forma
/// deliberada: si los peligros se distinguieran del resto, no habria nada
/// que inspeccionar.
///
/// La escena se compone desde datos. Anadir un escenario es escribir
/// contenido en `assets/content/scenarios/`, no pintar codigo nuevo.
class TechnicalScene extends StatelessWidget {
  const TechnicalScene({
    required this.scene,
    required this.hazards,
    required this.marks,
    required this.revealed,
    required this.onTapPoint,
    required this.semanticLabel,
    super.key,
  });

  final ScenarioScene scene;
  final List<Hazard> hazards;
  final List<HazardMark> marks;

  /// Tras cerrar la inspeccion se muestran los peligros no vistos.
  final bool revealed;

  final void Function(double x, double y) onTapPoint;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (TapUpDetails details) {
                final local = details.localPosition;
                onTapPoint(
                  (local.dx / constraints.maxWidth).clamp(0.0, 1.0),
                  (local.dy / constraints.maxHeight).clamp(0.0, 1.0),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _ScenePainter(
                    scene: scene,
                    hazards: hazards,
                    marks: marks,
                    revealed: revealed,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  const _ScenePainter({
    required this.scene,
    required this.hazards,
    required this.marks,
    required this.revealed,
  });

  final ScenarioScene scene;
  final List<Hazard> hazards;
  final List<HazardMark> marks;
  final bool revealed;

  static const Color _rock = Color(0xFF38434E);
  static const Color _rockLine = Color(0xFF2B3742);
  static const Color _void = Color(0xFF1E2830);
  static const Color _ink = Color(0xFFC7D2DC);
  static const Color _inkSoft = Color(0xFF8E9CA9);

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.shortestSide / 100;

    _paintRockMass(canvas, size);
    _paintOpening(canvas, size);
    _paintScaleTicks(canvas, size, unit);

    final ink = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = unit * 0.9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final element in scene.elements) {
      _paintElement(canvas, size, unit, ink, element);
    }

    _paintFeedback(canvas, size, unit);
  }

  // --- Fondo -------------------------------------------------------------

  void _paintRockMass(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _rock);

    // Trama del macizo: diagonales finas, como en un corte geologico.
    final hatch = Paint()
      ..color = _rockLine
      ..strokeWidth = 1;
    final step = size.width / 26;
    for (var x = -size.height; x < size.width; x += step) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        hatch,
      );
    }
  }

  /// Vano excavado, segun el perfil de la labor.
  Path _openingPath(Size size) {
    final w = size.width;
    final h = size.height;

    switch (scene.profile) {
      case SceneProfile.arch:
        return Path()
          ..moveTo(w * 0.06, h * 0.92)
          ..lineTo(w * 0.06, h * 0.34)
          ..quadraticBezierTo(w * 0.5, h * -0.04, w * 0.94, h * 0.34)
          ..lineTo(w * 0.94, h * 0.92)
          ..close();
      case SceneProfile.rect:
        return Path()
          ..moveTo(w * 0.05, h * 0.92)
          ..lineTo(w * 0.05, h * 0.08)
          ..lineTo(w * 0.95, h * 0.08)
          ..lineTo(w * 0.95, h * 0.92)
          ..close();
      case SceneProfile.ramp:
        return Path()
          ..moveTo(w * 0.04, h * 0.96)
          ..lineTo(w * 0.04, h * 0.30)
          ..lineTo(w * 0.96, h * 0.10)
          ..lineTo(w * 0.96, h * 0.74)
          ..close();
    }
  }

  void _paintOpening(Canvas canvas, Size size) {
    final opening = _openingPath(size);
    canvas.drawPath(opening, Paint()..color = _void);
    canvas.drawPath(
      opening,
      Paint()
        ..color = _inkSoft
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // Piso.
    final floorY = scene.profile == SceneProfile.ramp
        ? size.height * 0.80
        : size.height * 0.88;
    canvas.drawLine(
      Offset(size.width * 0.05, floorY),
      Offset(size.width * 0.95, floorY),
      Paint()
        ..color = _inkSoft
        ..strokeWidth = 1.4,
    );
  }

  /// Marcas de escala en el margen. Aportan la lectura de lamina tecnica.
  void _paintScaleTicks(Canvas canvas, Size size, double unit) {
    final tick = Paint()
      ..color = _inkSoft.withValues(alpha: 0.55)
      ..strokeWidth = 1;

    for (var i = 1; i < 10; i++) {
      final x = size.width * i / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, unit * 2), tick);
      final y = size.height * i / 10;
      canvas.drawLine(Offset(0, y), Offset(unit * 2, y), tick);
    }
  }

  // --- Simbolos ----------------------------------------------------------

  Rect _boxFor(SceneElement element, Size size) {
    return Rect.fromCenter(
      center: Offset(element.x * size.width, element.y * size.height),
      width: element.width * size.width,
      height: element.height * size.height,
    );
  }

  void _paintElement(
    Canvas canvas,
    Size size,
    double unit,
    Paint ink,
    SceneElement element,
  ) {
    final box = _boxFor(element, size);

    canvas.save();
    if (element.flip) {
      canvas.translate(box.center.dx, box.center.dy);
      canvas.scale(-1, 1);
      canvas.translate(-box.center.dx, -box.center.dy);
    }

    switch (element.type) {
      case 'looseRock':
        _rockBlock(canvas, box, ink, 1);
      case 'rubble':
        _rockBlock(canvas, box, ink, 3);
      case 'crack':
        _crack(canvas, box, ink);
      case 'duct':
        _duct(canvas, box, ink);
      case 'bolt':
        _bolt(canvas, box, ink);
      case 'worker':
        _worker(canvas, box, ink);
      case 'workerHigh':
        _worker(canvas, box, ink, platform: true);
      case 'sign':
        _sign(canvas, box, ink);
      case 'cable':
        _cable(canvas, box, ink);
      case 'puddle':
        _puddle(canvas, box, ink);
      case 'blastHoles':
        _blastHoles(canvas, box, ink);
      case 'gas':
        _stipple(canvas, box, 34, unit * 0.9);
      case 'dust':
        _stipple(canvas, box, 22, unit * 0.6);
      case 'barricade':
        _barricade(canvas, box, ink);
      case 'liftedArm':
        _liftedArm(canvas, box, ink);
      case 'panel':
        _panel(canvas, box, ink);
      case 'truck':
        _truck(canvas, box, ink);
      case 'tool':
        _tool(canvas, box, ink);
      case 'blindSpot':
        _blindSpot(canvas, box);
      case 'edge':
        _edge(canvas, box, ink);
      case 'fan':
        _fan(canvas, box, ink);
      case 'door':
        _door(canvas, box, ink);
      default:
        canvas.drawRect(box, ink);
    }

    canvas.restore();
  }

  void _rockBlock(Canvas canvas, Rect box, Paint ink, int count) {
    for (var i = 0; i < count; i++) {
      final shrink = 1 - i * 0.22;
      final r = Rect.fromCenter(
        center: box.center.translate(
          box.width * (i - (count - 1) / 2) * 0.30,
          box.height * 0.10 * i,
        ),
        width: box.width * shrink * 0.62,
        height: box.height * shrink * 0.72,
      );
      final path = Path()
        ..moveTo(r.left, r.top + r.height * 0.35)
        ..lineTo(r.left + r.width * 0.34, r.top)
        ..lineTo(r.right, r.top + r.height * 0.28)
        ..lineTo(r.right - r.width * 0.18, r.bottom)
        ..lineTo(r.left + r.width * 0.22, r.bottom - r.height * 0.12)
        ..close();
      canvas.drawPath(path, ink);
    }
  }

  void _crack(Canvas canvas, Rect box, Paint ink) {
    for (var i = 0; i < 2; i++) {
      final x = box.left + box.width * (0.25 + i * 0.42);
      final path = Path()
        ..moveTo(x, box.top)
        ..lineTo(x + box.width * 0.12, box.top + box.height * 0.32)
        ..lineTo(x - box.width * 0.06, box.top + box.height * 0.60)
        ..lineTo(x + box.width * 0.14, box.bottom);
      canvas.drawPath(path, ink);
    }
  }

  void _duct(Canvas canvas, Rect box, Paint ink) {
    final body = Rect.fromLTRB(
      box.left,
      box.center.dy - box.height * 0.26,
      box.right,
      box.center.dy + box.height * 0.26,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, Radius.circular(box.height * 0.26)),
      ink,
    );
    for (var i = 1; i < 4; i++) {
      final x = body.left + body.width * i / 4;
      canvas.drawLine(Offset(x, body.top), Offset(x, body.bottom), ink);
    }
  }

  void _bolt(Canvas canvas, Rect box, Paint ink) {
    canvas.drawLine(
      Offset(box.center.dx, box.top),
      Offset(box.center.dx, box.bottom),
      ink,
    );
    canvas.drawLine(
      Offset(box.left, box.bottom),
      Offset(box.right, box.bottom),
      ink,
    );
  }

  /// Silueta tecnica de persona, a escala. Sin rasgos: es una figura de
  /// referencia de lamina, no un personaje.
  void _worker(Canvas canvas, Rect box, Paint ink, {bool platform = false}) {
    final fill = Paint()..color = _ink;
    final head = box.width * 0.26;
    final headCenter = Offset(box.center.dx, box.top + head);

    canvas.drawCircle(headCenter, head * 0.62, fill);

    // Casco: arco sobre la cabeza.
    final helmet = Path()
      ..moveTo(headCenter.dx - head * 0.86, headCenter.dy - head * 0.10)
      ..arcToPoint(
        Offset(headCenter.dx + head * 0.86, headCenter.dy - head * 0.10),
        radius: Radius.circular(head * 0.86),
      )
      ..close();
    canvas.drawPath(helmet, fill);

    final body = Path()
      ..moveTo(box.center.dx - box.width * 0.30, box.bottom)
      ..lineTo(box.center.dx - box.width * 0.20, box.top + head * 1.7)
      ..lineTo(box.center.dx + box.width * 0.20, box.top + head * 1.7)
      ..lineTo(box.center.dx + box.width * 0.30, box.bottom)
      ..close();
    canvas.drawPath(body, fill);

    if (platform) {
      canvas.drawLine(
        Offset(box.left - box.width * 0.35, box.bottom),
        Offset(box.right + box.width * 0.35, box.bottom),
        ink,
      );
    }
  }

  void _sign(Canvas canvas, Rect box, Paint ink) {
    final top = Offset(box.center.dx, box.top);
    final size = box.width * 0.46;
    final diamond = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(top.dx + size, top.dy + size)
      ..lineTo(top.dx, top.dy + size * 2)
      ..lineTo(top.dx - size, top.dy + size)
      ..close();
    canvas.drawPath(diamond, ink);
    canvas.drawLine(
      Offset(box.center.dx, top.dy + size * 2),
      Offset(box.center.dx, box.bottom),
      ink,
    );
  }

  void _cable(Canvas canvas, Rect box, Paint ink) {
    final path = Path()..moveTo(box.left, box.center.dy);
    const steps = 4;
    for (var i = 0; i < steps; i++) {
      final x1 = box.left + box.width * (i + 0.5) / steps;
      final x2 = box.left + box.width * (i + 1) / steps;
      final dy = i.isEven ? -box.height * 0.42 : box.height * 0.42;
      path.quadraticBezierTo(x1, box.center.dy + dy, x2, box.center.dy);
    }
    canvas.drawPath(path, ink);
  }

  void _puddle(Canvas canvas, Rect box, Paint ink) {
    canvas.drawOval(box, ink);
    for (var i = 1; i < 3; i++) {
      final y = box.top + box.height * i / 3;
      canvas.drawLine(
        Offset(box.left + box.width * 0.22, y),
        Offset(box.right - box.width * 0.22, y),
        ink,
      );
    }
  }

  void _blastHoles(Canvas canvas, Rect box, Paint ink) {
    canvas.drawLine(
      Offset(box.left, box.bottom),
      Offset(box.right, box.bottom),
      ink,
    );
    for (var i = 0; i < 5; i++) {
      final x = box.left + box.width * (i + 0.5) / 5;
      final y = box.top + box.height * (i.isEven ? 0.30 : 0.58);
      canvas.drawCircle(Offset(x, y), box.width * 0.055, ink);
      canvas.drawLine(
        Offset(x, y),
        Offset(x, box.bottom),
        ink,
      );
    }
  }

  /// Nube de gas o de polvo: puntos con una distribucion fija.
  ///
  /// La secuencia es determinista para que la escena no cambie entre
  /// repintados y el estudiante no vea moverse lo que esta inspeccionando.
  void _stipple(Canvas canvas, Rect box, int count, double radius) {
    final dot = Paint()..color = _ink.withValues(alpha: 0.75);
    for (var i = 0; i < count; i++) {
      final a = i * 2.399963;
      final r = math.sqrt(i / count);
      final x = box.center.dx + math.cos(a) * r * box.width * 0.48;
      final y = box.center.dy + math.sin(a) * r * box.height * 0.48;
      canvas.drawCircle(Offset(x, y), radius * 0.5, dot);
    }
  }

  void _barricade(Canvas canvas, Rect box, Paint ink) {
    final bar = Rect.fromLTRB(
      box.left,
      box.center.dy - box.height * 0.16,
      box.right,
      box.center.dy + box.height * 0.16,
    );
    canvas.drawRect(bar, ink);
    for (var i = 0; i < 5; i++) {
      final x = bar.left + bar.width * i / 5;
      canvas.drawLine(
        Offset(x, bar.bottom),
        Offset(x + bar.width / 5, bar.top),
        ink,
      );
    }
    canvas.drawLine(
      Offset(box.left + box.width * 0.16, bar.bottom),
      Offset(box.left + box.width * 0.16, box.bottom),
      ink,
    );
    canvas.drawLine(
      Offset(box.right - box.width * 0.16, bar.bottom),
      Offset(box.right - box.width * 0.16, box.bottom),
      ink,
    );
  }

  void _liftedArm(Canvas canvas, Rect box, Paint ink) {
    final pivot = Offset(box.left + box.width * 0.12, box.bottom);
    canvas.drawCircle(pivot, box.width * 0.07, ink);
    canvas.drawLine(
      pivot,
      Offset(box.center.dx, box.top + box.height * 0.24),
      ink,
    );
    canvas.drawLine(
      Offset(box.center.dx, box.top + box.height * 0.24),
      Offset(box.right, box.top),
      ink,
    );
  }

  void _panel(Canvas canvas, Rect box, Paint ink) {
    canvas.drawRect(box, ink);
    // Puerta entreabierta.
    canvas.drawLine(
      Offset(box.right, box.top),
      Offset(box.right + box.width * 0.28, box.top + box.height * 0.14),
      ink,
    );
    canvas.drawLine(
      Offset(box.right, box.bottom),
      Offset(box.right + box.width * 0.28, box.bottom - box.height * 0.14),
      ink,
    );
    for (var i = 1; i < 4; i++) {
      final y = box.top + box.height * i / 4;
      canvas.drawLine(
        Offset(box.left + box.width * 0.22, y),
        Offset(box.right - box.width * 0.22, y),
        ink,
      );
    }
  }

  void _truck(Canvas canvas, Rect box, Paint ink) {
    final body = Path()
      ..moveTo(box.left, box.bottom - box.height * 0.24)
      ..lineTo(box.left + box.width * 0.10, box.center.dy)
      ..lineTo(box.left + box.width * 0.36, box.center.dy)
      ..lineTo(box.left + box.width * 0.44, box.top)
      ..lineTo(box.right, box.top)
      ..lineTo(box.right, box.bottom - box.height * 0.24)
      ..close();
    canvas.drawPath(body, ink);

    final wheel = box.height * 0.20;
    canvas.drawCircle(
      Offset(box.left + box.width * 0.22, box.bottom - wheel * 0.6),
      wheel,
      ink,
    );
    canvas.drawCircle(
      Offset(box.right - box.width * 0.20, box.bottom - wheel * 0.6),
      wheel,
      ink,
    );
  }

  void _tool(Canvas canvas, Rect box, Paint ink) {
    canvas.drawLine(
      Offset(box.left + box.width * 0.20, box.bottom),
      Offset(box.right - box.width * 0.20, box.top),
      ink,
    );
    canvas.drawCircle(
      Offset(box.right - box.width * 0.20, box.top + box.height * 0.14),
      box.height * 0.20,
      ink,
    );
  }

  void _blindSpot(Canvas canvas, Rect box) {
    final dash = Paint()
      ..color = _ink.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final apex = Offset(box.left, box.center.dy);
    for (var i = 0; i <= 4; i++) {
      final y = box.top + box.height * i / 4;
      canvas.drawLine(apex, Offset(box.right, y), dash);
    }
  }

  void _edge(Canvas canvas, Rect box, Paint ink) {
    canvas.drawLine(
      Offset(box.left, box.top),
      Offset(box.center.dx, box.top),
      ink,
    );
    canvas.drawLine(
      Offset(box.center.dx, box.top),
      Offset(box.center.dx, box.bottom),
      ink,
    );
    for (var i = 0; i < 4; i++) {
      final x = box.center.dx + box.width * (i + 1) / 8;
      canvas.drawLine(
        Offset(x, box.top),
        Offset(x - box.width * 0.06, box.bottom),
        ink,
      );
    }
  }

  void _fan(Canvas canvas, Rect box, Paint ink) {
    final radius = math.min(box.width, box.height) * 0.40;
    canvas.drawCircle(box.center, radius, ink);
    for (var i = 0; i < 3; i++) {
      final a = i * 2.0944;
      canvas.drawLine(
        box.center,
        Offset(
          box.center.dx + math.cos(a) * radius,
          box.center.dy + math.sin(a) * radius,
        ),
        ink,
      );
    }
    canvas.drawRect(
      Rect.fromCenter(
        center: box.center,
        width: radius * 2.4,
        height: radius * 2.4,
      ),
      ink,
    );
  }

  void _door(Canvas canvas, Rect box, Paint ink) {
    canvas.drawLine(
      Offset(box.left, box.top),
      Offset(box.left, box.bottom),
      ink,
    );
    final leaf = Path()
      ..moveTo(box.left, box.top)
      ..lineTo(box.right, box.top + box.height * 0.22)
      ..lineTo(box.right, box.bottom - box.height * 0.06)
      ..lineTo(box.left, box.bottom);
    canvas.drawPath(leaf, ink);
  }

  // --- Marcas del estudiante ---------------------------------------------

  void _paintFeedback(Canvas canvas, Size size, double unit) {
    for (final mark in marks) {
      final center = Offset(mark.x * size.width, mark.y * size.height);
      final hit = hazards.any((Hazard h) => h.area.contains(mark.x, mark.y));
      final color = revealed
          ? (hit ? AppColors.riskLow : AppColors.textSecondary)
          : Colors.white;

      canvas.drawCircle(
        center,
        unit * 3.2,
        Paint()..color = color.withValues(alpha: 0.22),
      );
      canvas.drawCircle(
        center,
        unit * 3.2,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = unit * 0.8,
      );
    }

    if (!revealed) {
      return;
    }

    for (final hazard in hazards) {
      final seen = marks.any(
        (HazardMark m) => hazard.area.contains(m.x, m.y),
      );
      if (seen) {
        continue;
      }
      final rect = Rect.fromLTWH(
        hazard.area.left * size.width,
        hazard.area.top * size.height,
        hazard.area.width * size.width,
        hazard.area.height * size.height,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(unit * 1.5)),
        Paint()
          ..color = AppColors.riskMedium
          ..style = PaintingStyle.stroke
          ..strokeWidth = unit,
      );
    }
  }

  @override
  bool shouldRepaint(_ScenePainter oldDelegate) {
    return oldDelegate.revealed != revealed ||
        oldDelegate.marks.length != marks.length ||
        oldDelegate.scene != scene;
  }
}
