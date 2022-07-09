import 'package:flutter_test/flutter_test.dart';
import 'package:fxpui/util/number_util.dart';

void main() {
  test('Format number less than 1000 without decimal', () {
    double num = 123;

    expect(formatNumber(num, true, 0), '123');
    expect(formatNumber(num, true, 1), '123.0');
    expect(formatNumber(num, true, 2), '123.00');
  });

  test('Format number greater than 1000 without decimal', () {
    double num = 1234;

    expect(formatNumber(num, true, 0), '1,234');
    expect(formatNumber(num, true, 1), '1,234.0');
    expect(formatNumber(num, true, 2), '1,234.00');
  });

  test('Format number greater than 1000000 without decimal', () {
    double num = 1234567;

    expect(formatNumber(num, true, 0), '1,234,567');
    expect(formatNumber(num, true, 1), '1,234,567.0');
    expect(formatNumber(num, true, 2), '1,234,567.00');
  });

  test('Format decimal part', () {
    double num = 123.1;

    expect(formatNumber(num, true, 0), '123');
    expect(formatNumber(num, true, 1), '123.1');
    expect(formatNumber(num, true, 2), '123.10');
  });

}
