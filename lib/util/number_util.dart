import 'package:intl/intl.dart';

String formatNumber(double numValue, bool thousandSeparator, int numOfDecimal) {
  final integerPart = thousandSeparator ? '#,###' : '#';
  final decimalPart = numOfDecimal > 0 ? '.' + '0' * numOfDecimal : '';
  return NumberFormat('$integerPart$decimalPart').format(numValue);
}