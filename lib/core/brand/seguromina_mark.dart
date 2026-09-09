import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Marca grafica de SeguroMina.
///
/// Se dibuja con [CustomPainter] y no desde un SVG por tres motivos: aparece
/// en el splash, donde cargar un asset introduce un parpadeo; se anima el
/// destello sobre el escudo; y los tests de widget no dependen del bundle.
/// El mismo trazado esta replicado en `assets/brand/seguromina_logo.svg`
/// para el icono de aplicacion y la ficha de Google Play.
///
/// Composicion: escudo (proteccion) que contiene un casco minero con lampara
/// (el oficio, y la lampara hace de ojo de inspeccion) sobre un check
/// (la decision validada). La silueta es angular y vertical de forma
/// deliberada, para no confundirse con marcas circulares o radiales.
class SeguroMinaMark extends StatelessWidget {
  const SeguroMinaMark({
    super.key,
    this.size = 64,
    this.onDark = false,
    this.shine = 0,
  });

  /// Lado del cuadrado que ocupa la marca.
  final double size;

  /// Anade un filete claro alrededor del escudo.
  ///
  /// El azul de marca sobre el fondo oscuro de la app queda en 2.5:1, por
  /// debajo del 3:1 que pide WCAG 1.4.11 para graficos. El filete separa la
  /// silueta sin alterar los colores de marca.
  final bool onDark;

  /// Posicion del destello que recorre el escudo, de 0 a 1. En 0 no se dibuja.
  final double shine;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _MarkPainter(onDark: onDark, shine: shine),
        ),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.onDark, required this.shine});

  final bool onDark;
  final double shine;

  /// El trazado esta definido sobre una reticula de 64x64 y se escala.
  static const double _grid = 64;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / _grid;

    canvas.save();
    canvas.translate(
      (size.width - _grid * scale) / 2,
      (size.height - _grid * scale) / 2,
    );
    canvas.scale(scale);

    final shield = _shieldPath();
    _paintShield(canvas, shield);
    _paintHelmet(canvas);
    _paintCheck(canvas);
    if (shine > 0) {
      _paintShine(canvas, shield);
    }

    canvas.restore();
  }

  Path _shieldPath() {
    return Path()
      ..moveTo(14, 8)
      ..lineTo(50, 8)
      ..quadraticBezierTo(54, 8, 54, 12)
      ..lineTo(54, 30)
      ..cubicTo(54, 45, 45, 55, 32, 60)
      ..cubicTo(19, 55, 10, 45, 10, 30)
      ..lineTo(10, 12)
      ..quadraticBezierTo(10, 8, 14, 8)
      ..close();
  }

  void _paintShield(Canvas canvas, Path shield) {
    canvas.drawPath(shield, Paint()..color = AppColors.primary);

    if (!onDark) {
      return;
    }
    canvas.drawPath(
      shield,
      Paint()
        ..color = AppColors.textPrimaryDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _paintHelmet(Canvas canvas) {
    final dome = Path()
      ..moveTo(20, 33)
      ..cubicTo(20, 20, 44, 20, 44, 33)
      ..close();
    final helmet = Paint()..color = AppColors.secondary;
    canvas.drawPath(dome, helmet);

    canvas.drawRRect(
      RRect.fromLTRBR(16, 32.4, 48, 37, const Radius.circular(2.3)),
      helmet,
    );

    // La lampara hace de ojo de inspeccion. Va en gris oscuro sobre el
    // amarillo (6.7:1) y no en blanco, que sobre amarillo queda en 1.6:1.
    canvas.drawCircle(
      const Offset(32, 26.5),
      3.6,
      Paint()..color = AppColors.textPrimary,
    );
    canvas.drawCircle(
      const Offset(30.9, 25.4),
      1.15,
      Paint()..color = Colors.white,
    );
  }

  void _paintCheck(Canvas canvas) {
    final check = Path()
      ..moveTo(23, 45)
      ..lineTo(29.5, 51.3)
      ..lineTo(43, 40);

    canvas.drawPath(
      check,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  /// Banda diagonal que recorre el escudo durante el splash.
  void _paintShine(Canvas canvas, Path shield) {
    canvas.save();
    canvas.clipPath(shield);

    final x = -30 + shine * 120;
    final band = Path()
      ..moveTo(x, 64)
      ..lineTo(x + 16, 64)
      ..lineTo(x + 40, 0)
      ..lineTo(x + 24, 0)
      ..close();

    canvas.drawPath(
      band,
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) {
    return oldDelegate.onDark != onDark || oldDelegate.shine != shine;
  }
}
