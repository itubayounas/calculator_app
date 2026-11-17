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
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
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
          const SizedBox(height: 8),
          AnimatedOpacity(
            opacity: showError ? 1 : 0,
            duration: const Duration(milliseconds: 250),
            child: Text(
              errorText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.error, fontSize: 14),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              expression,
              style: TextStyle(fontSize: 22, color: colors.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 4),
          // Expanded + FittedBox, instead of a guessed fixed height: this
          // takes whatever space is actually left and scales the number to
          // fit it exactly, so it's physically impossible for it to overflow
          // regardless of screen size.
          Expanded(
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