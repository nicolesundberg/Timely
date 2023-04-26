import 'package:flutter_test/flutter_test.dart';
import 'package:timely/backend_models/double_precision.dart';

void main() {
  test('doublePrecision: no rounding needed', () {
    double testValue = 123456.789;
    expect(doublePrecision(testValue, 9, 4), 123456.789);
  });

  test('doublePrecision: round decimals', () {
    double testValue = 123456.789;
    expect(doublePrecision(testValue, 9, 2), 123456.79);
  });

  test('doublePrecision: all round decimals', () {
    double testValue = 123456.789;
    expect(doublePrecision(testValue, 9, 0), 123457.0);
  });

  test('doublePrecision: round from maxDigit limit', () {
    double testValue = 123456.789;
    expect(doublePrecision(testValue, 5, 4), 123460.0);
  });

  test('doublePrecision: round decimals from maxDigit limit', () {
    double testValue = 123456.789;
    expect(doublePrecision(testValue, 7, 4), 123456.8);
  });

  test('doublePrecision: round all decimals from maxDigit limit', () {
    double testValue = 123456.789;
    expect(doublePrecision(testValue, 6, 5), 123457.0);
  });

  test('doublePrecision: no rounding needed', () {
    double testValue = 987654.321;
    expect(doublePrecision(testValue, 10, 3), 987654.321);
  });

  test('doublePrecision: round decimals', () {
    double testValue = 987654.321;
    expect(doublePrecision(testValue, 10, 1), 987654.3);
  });

  test('doublePrecision: round all decimals', () {
    double testValue = 987654.321;
    expect(doublePrecision(testValue, 10, 0), 987654.0);
  });

  test('doublePrecision: round from maxDigit limit', () {
    double testValue = 987654.321;
    expect(doublePrecision(testValue, 3, 2), 988000.0);
  });

  test('doublePrecision: round decimals from maxDigit limit', () {
    double testValue = 987654.321;
    expect(doublePrecision(testValue, 8, 3), 987654.32);
  });

  test('doublePrecision: round all decimals from maxDigit limit', () {
    double testValue = 987654.321;
    expect(doublePrecision(testValue, 6, 2), 987654.0);
  });
}