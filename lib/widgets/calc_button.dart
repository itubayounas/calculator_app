import 'package:flutter/material.dart';

enum CalcButtonType { number, operator, function, equals }

class CalcButton extends StatefulWidget {
  final String label;
  final CalcButtonType type;
  final VoidCallback onPressed;

  const CalcButton({
    super.key,
    required this.label,
    required this.type,
    required this.onPressed,
  });

  @override
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    Color background;
    Color foreground;
    switch (widget.type) {
      case CalcButtonType.number:
        background = colors.surfaceContainerHighest;
        foreground = colors.onSurface;
        break;
      case CalcButtonType.function:
        background = colors.secondaryContainer;
        foreground = colors.onSecondaryContainer;
        break;
      case CalcButtonType.operator:
        background = colors.tertiaryContainer;
        foreground = colors.onTertiaryContainer;
        break;
      case CalcButtonType.equals:
        background = colors.primary;
        foreground = colors.onPrimary;
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(5),
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _pressed ? 0.90 : 1.0,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(24),
              boxShadow: _pressed
                  ? []
                  : [
                      BoxShadow(
                        color: background.withValues(alpha: 0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: widget.onPressed,
                child: Center(
                  child: widget.label == '⌫'
                      ? Icon(Icons.backspace_outlined, color: foreground)
                      : Text(
                          widget.label,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w500,
                            color: foreground,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}