import 'package:flutter/material.dart';

// Button that swaps its label for a spinner while an async action runs.
class LoadingButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;
  final bool outlined;
  final IconData? icon;

  const LoadingButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
    this.outlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const spinner = SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(strokeWidth: 2.5),
    );

    final Widget child = isLoading
        ? spinner
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
              Text(label),
            ],
          );

    final handler = isLoading ? null : onPressed;

    return SizedBox(
      height: 52,
      width: double.infinity,
      child: outlined
          ? OutlinedButton(onPressed: handler, child: child)
          : FilledButton(onPressed: handler, child: child),
    );
  }
}
