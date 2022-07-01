import 'package:intl/intl.dart';

const languageEn = 'en';
const languageHant = 'hant';
const languageHans = 'hans';

final _fallbackNumberFormat = NumberFormat('#,###.00');
final numberFormatMap = {
  0: NumberFormat('#,###'),
  1: NumberFormat('#,###.0'),
  2: NumberFormat('#,###.00'),
  3: NumberFormat('#,###.000'),
  4: NumberFormat('#,###.000'),
};

int getLoaderVisibleTimeInMilliseconds() {
  return 1000;
}

int getSnackBarVisibleMilliseconds() {
  return 3000;
}

String formatNumber(double value, int precision) {
  return (numberFormatMap[precision] ?? _fallbackNumberFormat).format(value);
}

const dateFormatStr = 'yyyy-MM-dd';

final dateFormat = DateFormat(dateFormatStr);

final dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

const pageSize = 50;
