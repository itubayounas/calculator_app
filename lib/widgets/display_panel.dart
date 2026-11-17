import 'package:flutter/material.dart';

class DisplayPanel extends StatelessWidget {
  final String expression;
  final String value;
  final String errorText;
  final bool showError;

  const DisplayPanel({
    super.key,
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
          // fixed height, so the error fading in never moves anything
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
          SizedBox(
            height: 80,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 68,
                  fontWeight: FontWeight.w300,
                  color: colors.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
