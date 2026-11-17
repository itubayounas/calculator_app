// Form validators. Each returns an error message, or null when the value is fine.

class Validators {
  static final RegExp _emailRegex =
      RegExp(r'^[\w.+\-]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)*\.[A-Za-z]{2,}$');

  static String? email(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Please enter your email';
    if (!_emailRegex.hasMatch(text)) return 'Enter a valid email (name@domain.com)';
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Please enter a password';
    if (text.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if ((value ?? '').isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }
}
