import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/training/hazard.dart';
import '../../../domain/training/mission_scoring.dart';

/// Escena esquematica de una galeria de acceso.
///
/// Es un esquema y no una fotografia por decision pedagogica: en una foto el
/// estudiante busca el detalle llamativo, en un esquema tiene que leer la
/// situacion. Ademas se dibuja con [CustomPainter], asi que escala a
/// cualquier pantalla y no anade peso a la descarga.
class HazardScene extends StatelessWidget {
  const HazardScene({
    required this.hazards,
    required this.marks,
    required this.revealed,
    required this.onTapPoint,
    required this.semanticLabel,
    super.key,
  });

  final List<Hazard> hazards;
  final List<HazardMark> marks;

  /// Tras terminar la inspeccion se muestran tambien los peligros no vistos.
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
                borderRadius: BorderRadius.circular(16),
                child: CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _ScenePainter(
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
    required this.hazards,
    required this.marks,
    required this.revealed,
  });

  final List<Hazard> hazards;
  final List<HazardMark> marks;
  final bool revealed;

  static const Color _rock = Color(0xFF3B4A57);
  static const Color _rockDark = Color(0xFF2B3742);
  static const Color _floor = Color(0xFF4A5661);
  static const Color _opening = Color(0xFF22303B);
  static const Color _shadow = Color(0xFF17212A);

  @override
  void paint(Canvas canvas, Size size) {
    _paintGallery(canvas, size);
    _paintFracturedRock(canvas, size);
    _paintWorker(canvas, size);
    _paintCable(canvas, size);
    _paintFeedback(canvas, size);
  }

  Offset _at(Size size, double x, double y) {
    return Offset(x * size.width, y * size.height);
  }

  void _paintGallery(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _rock);

    final arch = Path()
      ..moveTo(size.width * 0.18, size.height)
      ..lineTo(size.width * 0.18, size.height * 0.42)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.02,
        size.width * 0.82,
        size.height * 0.42,
      )
      ..lineTo(size.width * 0.82, size.height)
      ..close();
    canvas.drawPath(arch, Paint()..color = _opening);

    canvas.drawRect(
      Rect.fromLTRB(0, size.height * 0.78, size.width, size.height),
      Paint()..color = _floor,
    );
    canvas.drawRect(
      Rect.fromLTRB(0, size.height * 0.78, size.width, size.height * 0.80),
      Paint()..color = _rockDark,
    );
  }

  /// Roca fracturada en el techo, arriba a la derecha.
  void _paintFracturedRock(Canvas canvas, Size size) {
    final block = Path()
      ..moveTo(size.width * 0.60, size.height * 0.16)
      ..lineTo(size.width * 0.76, size.height * 0.13)
      ..lineTo(size.width * 0.86, size.height * 0.24)
      ..lineTo(size.width * 0.72, size.height * 0.34)
      ..lineTo(size.width * 0.62, size.height * 0.27)
      ..close();
    canvas.drawPath(block, Paint()..color = _rockDark);

    final crack = Paint()
      ..color = _shadow
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.008
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.62, size.height * 0.17)
        ..lineTo(size.width * 0.69, size.height * 0.23)
        ..lineTo(size.width * 0.65, size.height * 0.28)
        ..lineTo(size.width * 0.71, size.height * 0.33),
      crack,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.75, size.height * 0.14)
        ..lineTo(size.width * 0.78, size.height * 0.22)
        ..lineTo(size.width * 0.85, size.height * 0.25),
      crack,
    );
  }

  /// Trabajador sin lentes de seguridad, al centro.
  void _paintWorker(Canvas canvas, Size size) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        size.width * 0.47,
        size.height * 0.52,
        size.width * 0.61,
        size.height * 0.80,
      ),
      Radius.circular(size.width * 0.03),
    );
    canvas.drawRRect(body, Paint()..color = AppColors.primary);

    // Lleva chaleco reflectivo: lo que falta son los lentes. La escena no
    // debe sugerir que va sin ningun equipo.
    canvas.drawRect(
      Rect.fromLTRB(
        size.width * 0.47,
        size.height * 0.62,
        size.width * 0.61,
        size.height * 0.65,
      ),
      Paint()..color = AppColors.secondary,
    );

    final head = _at(size, 0.54, 0.475);
    canvas.drawCircle(
      head,
      size.width * 0.042,
      Paint()..color = const Color(0xFFD9A87C),
    );

    final helmet = Path()
      ..moveTo(head.dx - size.width * 0.052, head.dy)
      ..arcToPoint(
        Offset(head.dx + size.width * 0.052, head.dy),
        radius: Radius.circular(size.width * 0.052),
      )
      ..close();
    canvas.drawPath(helmet, Paint()..color = AppColors.secondary);

    // Ojos descubiertos: sin proteccion ocular.
    final eye = Paint()..color = _shadow;
    canvas.drawCircle(
      Offset(head.dx - size.width * 0.016, head.dy + size.height * 0.014),
      size.width * 0.007,
      eye,
    );
    canvas.drawCircle(
      Offset(head.dx + size.width * 0.016, head.dy + size.height * 0.014),
      size.width * 0.007,
      eye,
    );
  }

  /// Cable electrico tendido en el piso, abajo a la izquierda.
  void _paintCable(Canvas canvas, Size size) {
    final cable = Path()
      ..moveTo(size.width * 0.04, size.height * 0.86)
      ..cubicTo(
        size.width * 0.16,
        size.height * 0.78,
        size.width * 0.28,
        size.height * 0.92,
        size.width * 0.40,
        size.height * 0.82,
      );

    canvas.drawPath(
      cable,
      Paint()
        ..color = const Color(0xFF1D262E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.016
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: _at(size, 0.40, 0.82),
        width: size.width * 0.035,
        height: size.height * 0.045,
      ),
      Paint()..color = AppColors.riskMedium,
    );
  }

  /// Marcas del estudiante y, al terminar, los peligros no vistos.
  void _paintFeedback(Canvas canvas, Size size) {
    for (final mark in marks) {
      final center = _at(size, mark.x, mark.y);
      final hit = hazards.any((Hazard h) => h.area.contains(mark.x, mark.y));
      final color = revealed
          ? (hit ? AppColors.riskLow : AppColors.textSecondary)
          : Colors.white;

      canvas.drawCircle(
        center,
        size.width * 0.030,
        Paint()..color = color.withValues(alpha: 0.28),
      );
      canvas.drawCircle(
        center,
        size.width * 0.030,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.008,
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
        RRect.fromRectAndRadius(rect, Radius.circular(size.width * 0.02)),
        Paint()
          ..color = AppColors.riskMedium
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.010,
      );
    }
  }

  @override
  bool shouldRepaint(_ScenePainter oldDelegate) {
    return oldDelegate.revealed != revealed ||
        oldDelegate.marks.length != marks.length;
  }
}
