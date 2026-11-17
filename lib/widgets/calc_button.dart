import 'package:flutter/material.dart';

enum CalcButtonType { number, operator, function, equals }

class CalcButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    Color background;
    Color foreground;
    switch (type) {
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
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onPressed,
          child: Center(
            child: label == '⌫'
                ? Icon(Icons.backspace_outlined, color: foreground)
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: foreground,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
