// The calculator brain. Plain Dart: NO Flutter imports, so it can be
// unit tested without building any widgets.
//
// State machine: current value (what is on screen), previous value,
// pending operator. Operations are chained left-to-right like a pocket
// calculator, so 4 + 5 × 2 = gives 18.

import '../utils/exceptions.dart';

class CalculationResult {
  final String expression; // e.g. "9 × 2"
  final String result; // e.g. "18"

  const CalculationResult({required this.expression, required this.result});
}

class CalculatorEngine {
  static const int maxDigits = 12;

  String _current = '0';
  double? _previous;
  String? _operator;
  String _expr = ''; // the small line above the result
  bool _overwrite = false; // next digit replaces the screen instead of appending
  bool _awaitingOperand = false; // an operator was just pressed

  String get display => _current;
  String get expression => _expr.trim();
  bool get canClearEntry => _current != '0' && !_overwrite;

  // ---------- Input ----------

  void inputDigit(String digit) {
    _awaitingOperand = false;
    if (_overwrite) {
      if (_operator == null) _expr = ''; // starting fresh after "="
      _current = digit;
      _overwrite = false;
      return;
    }
    final digitCount = _current.replaceAll(RegExp(r'[-.]'), '').length;
    if (digitCount >= maxDigits) throw const InputTooLongException();

    if (_current == '0') {
      _current = digit;
    } else if (_current == '-0') {
      _current = '-$digit';
    } else {
      _current += digit;
    }
  }

  void inputDecimal() {
    _awaitingOperand = false;
    if (_overwrite) {
      if (_operator == null) _expr = '';
      _current = '0.';
      _overwrite = false;
      return;
    }
    if (!_current.contains('.')) _current += '.';
  }

  void toggleSign() {
    if (_current == '0') return;
    _current = _current.startsWith('-') ? _current.substring(1) : '-$_current';
  }

  void backspace() {
    if (_overwrite) return; // don't chew into a finished result
    if (_current.length <= 1 || (_current.length == 2 && _current.startsWith('-'))) {
      _current = '0';
    } else {
      _current = _current.substring(0, _current.length - 1);
    }
  }

  // C clears the number being typed, AC clears everything.
  void clear() {
    if (canClearEntry) {
      _current = '0';
    } else {
      allClear();
    }
  }

  void allClear() {
    _current = '0';
    _previous = null;
    _operator = null;
    _expr = '';
    _overwrite = false;
    _awaitingOperand = false;
  }

  void percent() {
    final value = double.parse(_current);
    double result;
    // "50 + 10 %" means 10% of 50, like a real calculator
    if (_operator != null && !_awaitingOperand && (_operator == '+' || _operator == '−')) {
      result = _previous! * value / 100;
    } else {
      result = value / 100;
    }
    _current = _format(result);
    _overwrite = true;
    _awaitingOperand = false;
  }

  void inputOperator(String op) {
    // user pressed an operator and changed their mind
    if (_operator != null && _awaitingOperand) {
      _operator = op;
      _expr = '${_expr.substring(0, _expr.length - 2)}$op ';
      return;
    }

    final value = double.parse(_current);
    if (_operator != null) {
      // second operand was typed: evaluate what we have so far (left-to-right)
      final result = _calculate(_previous!, _operator!, value);
      _expr += '$_current $op ';
      _previous = result;
      _current = _format(result);
    } else {
      _previous = value;
      _expr = '$_current $op ';
    }
    _operator = op;
    _overwrite = true;
    _awaitingOperand = true;
  }

  // Returns null when there is nothing to calculate.
  CalculationResult? equals() {
    if (_operator == null) return null;

    final right = double.parse(_current);
    final fullExpression = '$_expr$_current';
    final result = _calculate(_previous!, _operator!, right);
    final text = _format(result);

    _previous = null;
    _operator = null;
    _expr = '$fullExpression =';
    _current = text;
    _overwrite = true;
    _awaitingOperand = false;

    return CalculationResult(expression: fullExpression, result: text);
  }

  // Used when the user taps an entry in the history screen.
  void loadValue(String value) {
    _current = value;
    _overwrite = true;
    _awaitingOperand = false;
  }

  // ---------- Internals ----------

  double _calculate(double a, String op, double b) {
    double result;
    switch (op) {
      case '+':
        result = a + b;
        break;
      case '−':
        result = a - b;
        break;
      case '×':
        result = a * b;
        break;
      case '÷':
        if (b == 0) {
          allClear();
          throw const DivisionByZeroException();
        }
        result = a / b;
        break;
      default:
        result = b;
    }
    if (result.isNaN || result.isInfinite) {
      allClear();
      throw const InvalidResultException();
    }
    return result;
  }

  // Turns a double into a clean string: 0.1 + 0.2 shows 0.3, not 0.30000000000000004
  String _format(double value) {
    if (value == 0) return '0'; // also avoids "-0"
    if (value == value.roundToDouble() && value.abs() < 1e12) {
      return value.toInt().toString();
    }
    final rounded = double.parse(value.toStringAsPrecision(12));
    var text = rounded.toString();
    if (text.contains('e')) return text;
    if (text.contains('.')) {
      text = text.replaceFirst(RegExp(r'0+$'), '');
      text = text.replaceFirst(RegExp(r'\.$'), '');
    }
    return text;
  }
}
