import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_app/utils/validators.dart';

void main() {
  test('email validation', () {
    expect(Validators.email('a@b.com'), isNull);
    expect(Validators.email('not-an-email'), isNotNull);
    expect(Validators.email(''), isNotNull);
  });

  test('password needs 6+ characters', () {
    expect(Validators.password('12345'), isNotNull);
    expect(Validators.password('123456'), isNull);
  });

  test('confirm password must match', () {
    expect(Validators.confirmPassword('abc123', 'abc123'), isNull);
    expect(Validators.confirmPassword('abc124', 'abc123'), isNotNull);
  });
}