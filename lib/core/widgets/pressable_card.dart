import 'package:flutter/material.dart';

import '../theme/app_typography.dart';

/// Tarjeta que responde al toque con un hundido breve.
///
/// La microanimacion no es adorno: confirma que el toque se registro antes de
/// que la pantalla siguiente termine de construirse.
class PressableCard extends StatefulWidget {
  const PressableCard({
    required this.onTap,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.semanticLabel,
    super.key,
  });

  final VoidCallback onTap;
  final Color? color;
  final EdgeInsets padding;
  final String? semanticLabel;
  final Widget child;

  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard> {
  bool _pressed = false;

  void _setPressed({required bool value}) {
    if (_pressed == value) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background =
        widget.color ?? theme.colorScheme.surfaceContainerHighest;

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => _setPressed(value: true),
            onTapUp: (_) => _setPressed(value: false),
            onTapCancel: () => _setPressed(value: false),
            child: Padding(
              padding: widget.padding,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
