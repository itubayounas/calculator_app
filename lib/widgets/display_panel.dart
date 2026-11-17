import 'package:flutter/material.dart';

class DisplayPanel extends StatelessWidget {
  final String greeting;
  final String expression;
  final String value;
  final String errorText;
  final bool showError;

  const DisplayPanel({
    super.key,
    required this.greeting,
    required this.expression,
    required this.value,
    required this.errorText,
    required this.showError,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Greeting fades + slides in once when the screen first appears.
          Align(
            alignment: Alignment.centerLeft,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              builder: (context, t, child) => Opacity(
                opacity: t,
                child: Transform.translate(offset: Offset(0, (1 - t) * 8), child: child),
              ),
              child: Text(
                greeting,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: colors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 24,
            child: AnimatedOpacity(
              opacity: showError ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              child: Text(
                errorText,
                style: TextStyle(color: colors.error, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 28,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                expression,
                style: TextStyle(fontSize: 22, color: colors.onSurfaceVariant),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Was 80 — too tight for a 68px font's natural line height, which
          // is what caused the "BOTTOM OVERFLOWED BY 21 PIXELS" warning.
          SizedBox(
            height: 104,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween(begin: 0.85, end: 1.0).animate(animation),
                    child: child,
                  ),
                ),
                child: Text(
                  value,
                  // key forces AnimatedSwitcher to treat each new value as a
                  // fresh widget so it actually animates on every change
                  key: ValueKey(value),
                  style: TextStyle(
                    fontSize: 68,
                    fontWeight: FontWeight.w300,
                    height: 1.0,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}