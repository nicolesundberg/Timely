import 'dart:math';

/// Rounds a double down to the maximum number of digits, with
/// a limited number of decimal places
double doublePrecision(double value, int maxDigits, int decimalLimit) {
  String string = value.toString();
  // Round off decimals as requested
  var removeDecimals = pow(10, decimalLimit);
  double rounded = (double.parse(string) * removeDecimals).round() / removeDecimals;
  string = rounded.toString();
  // Round off total digits to match
  var removeDigits = pow(10, maxDigits - string.substring(0, string.indexOf('.')).length);
  return (double.parse(string) * removeDigits).round() / removeDigits;
}