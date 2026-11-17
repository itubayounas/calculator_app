// Every failure in the app has its own named exception type.
// The UI decides what to show by catching the right type, never by parsing strings.

// ---------- Calculator ----------
abstract class CalculatorException implements Exception {
  final String message;
  const CalculatorException(this.message);

  @override
  String toString() => message;
}

class DivisionByZeroException extends CalculatorException {
  const DivisionByZeroException() : super('Cannot divide by zero');
}

class InvalidResultException extends CalculatorException {
  const InvalidResultException() : super('Result is too large to display');
}

class InputTooLongException extends CalculatorException {
  const InputTooLongException() : super('Maximum of 12 digits reached');
}

// ---------- Auth ----------
abstract class AppAuthException implements Exception {
  final String message;
  const AppAuthException(this.message);

  @override
  String toString() => message;
}

class InvalidEmailException extends AppAuthException {
  const InvalidEmailException() : super('That email address is not valid.');
}

class WrongCredentialsException extends AppAuthException {
  const WrongCredentialsException() : super('Incorrect email or password.');
}

class UserNotFoundException extends AppAuthException {
  const UserNotFoundException()
      : super('No account found with that email address.');
}

class EmailAlreadyInUseException extends AppAuthException {
  const EmailAlreadyInUseException()
      : super('An account with this email already exists.');
}

class WeakPasswordException extends AppAuthException {
  const WeakPasswordException()
      : super('Password is too weak. Use at least 6 characters.');
}

class UserDisabledException extends AppAuthException {
  const UserDisabledException() : super('This account has been disabled.');
}

class TooManyRequestsException extends AppAuthException {
  const TooManyRequestsException()
      : super('Too many attempts. Please wait a bit and try again.');
}

class NetworkException extends AppAuthException {
  const NetworkException()
      : super('No internet connection. Check your network and try again.');
}

class GoogleSignInCancelledException extends AppAuthException {
  const GoogleSignInCancelledException() : super('Google sign-in was cancelled.');
}

class UnknownAuthException extends AppAuthException {
  const UnknownAuthException()
      : super('Something went wrong. Please try again.');
}

// ---------- History ----------
class HistorySyncException implements Exception {
  final String message;
  const HistorySyncException(
      [this.message = 'Saved on this device, but could not sync to the cloud']);

  @override
  String toString() => message;
}
