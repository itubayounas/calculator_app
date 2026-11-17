import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_app/services/calculator_engine.dart';
import 'package:calculator_app/utils/exceptions.dart';

void type(CalculatorEngine e, String number) {
  for (final ch in number.split('')) {
    ch == '.' ? e.inputDecimal() : e.inputDigit(ch);
  }
}

void main() {
  late CalculatorEngine engine;

  setUp(() => engine = CalculatorEngine());

  test('basic addition', () {
    type(engine, '12');
    engine.inputOperator('+');
    type(engine, '8');
    final result = engine.equals();
    expect(result!.result, '20');
    expect(result.expression, '12 + 8');
  });

  test('chained operations go left to right: 4 + 5 × 2 = 18', () {
    type(engine, '4');
    engine.inputOperator('+');
    type(engine, '5');
    engine.inputOperator('×');
    type(engine, '2');
    expect(engine.equals()!.result, '18');
  });

  test('0.1 + 0.2 shows 0.3', () {
    type(engine, '0.1');
    engine.inputOperator('+');
    type(engine, '0.2');
    expect(engine.equals()!.result, '0.3');
  });

  test('division by zero throws and resets', () {
    type(engine, '5');
    engine.inputOperator('÷');
    type(engine, '0');
    expect(() => engine.equals(), throwsA(isA<DivisionByZeroException>()));
    expect(engine.display, '0');
  });

  test('percent of previous value after plus', () {
    type(engine, '50');
    engine.inputOperator('+');
    type(engine, '10');
    engine.percent();
    expect(engine.equals()!.result, '55');
  });

  test('plain percent divides by 100', () {
    type(engine, '50');
    engine.percent();
    expect(engine.display, '0.5');
  });

  test('sign toggle and backspace', () {
    type(engine, '25');
    engine.toggleSign();
    expect(engine.display, '-25');
    engine.backspace();
    expect(engine.display, '-2');
    engine.backspace();
    expect(engine.display, '0');
  });

  test('only one decimal point allowed', () {
    type(engine, '1.5');
    engine.inputDecimal();
    expect(engine.display, '1.5');
  });

  test('too many digits throws', () {
    type(engine, '123456789012');
    expect(() => engine.inputDigit('3'), throwsA(isA<InputTooLongException>()));
  });

  test('equals with no operator does nothing', () {
    type(engine, '7');
    expect(engine.equals(), isNull);
  });

  test('changing operator replaces the previous one', () {
    type(engine, '6');
    engine.inputOperator('+');
    engine.inputOperator('×');
    type(engine, '3');
    expect(engine.equals()!.result, '18');
  });
}