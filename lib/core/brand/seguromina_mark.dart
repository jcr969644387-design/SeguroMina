import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Marca grafica de SeguroMina.
///
/// Un escudo trazado a linea que contiene dos estratos desplazados por una
/// falla. La falla no se dibuja: se lee en el salto entre los estratos, que
/// es exactamente como se representa en un corte geologico. Tres trazos en
/// total, para que la marca siga siendo legible a 24 px.
///
/// De una sola tinta, y no en dos colores, por una razon medida: el amarillo
/// de marca sobre blanco da 1.64:1, muy por debajo del 3:1 que WCAG 1.4.11
/// pide para graficos. Con relleno se sostenia; en un trazado a linea seria
/// invisible. El amarillo queda donde corresponde, que es senalar riesgo
/// dentro de la aplicacion, no decorar la marca.
///
/// El mismo trazado esta replicado en `assets/brand/seguromina_logo.svg`
/// para el icono de aplicacion y la ficha de Google Play.
class SeguroMinaMark extends StatelessWidget {
  const SeguroMinaMark({
    super.key,
    this.size = 64,
    this.onDark = false,
  });

  /// Lado del cuadrado que ocupa la marca.
  final double size;

  /// Usa la variante clara del azul.
  ///
  /// El azul de marca sobre el fondo oscuro de la app se queda en 2.50:1.
  /// Sin relleno que compense, la silueta desaparece.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _MarkPainter(onDark: onDark)),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.onDark});

  final bool onDark;

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

    final ink = onDark ? AppColors.primaryLight : AppColors.primary;
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(_shieldPath(), stroke);
    canvas.drawLine(const Offset(15, 28), const Offset(31, 28), stroke);
    canvas.drawLine(const Offset(33, 40), const Offset(47, 40), stroke);

    canvas.restore();
  }

  /// Escudo con el trazo por dentro del borde, para que no se recorte.
  Path _shieldPath() {
    return Path()
      ..moveTo(14, 9)
      ..lineTo(50, 9)
      ..quadraticBezierTo(53, 9, 53, 12)
      ..lineTo(53, 30)
      ..cubicTo(53, 44, 44, 53, 32, 58)
      ..cubicTo(20, 53, 11, 44, 11, 30)
      ..lineTo(11, 12)
      ..quadraticBezierTo(11, 9, 14, 9)
      ..close();
  }

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) {
    return oldDelegate.onDark != onDark;
  }
}
