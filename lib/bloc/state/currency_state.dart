import '../../model/currency.dart';

class CurrencySearchState {
  final bool loading;
  final List<Currency>? currencyList;
  late final Map<String, int> precisionMap;
  final String? errorCode;
  final List<String> errorParams;
  final int lastActionTime;

  // CurrencySearchState({
  //   this.loading = false,
  //   this.currencyList,
  //   this.errorCode,
  //   this.errorParams = const [],
  //   required this.lastActionTime,
  // }) {
  //   precisionMap = currencyList == null ? {} : {for (var e in currencyList ?? <Currency>[]) e.isoCcy: e.precision};
  // }

  CurrencySearchState.initial()
      : loading = false,
        currencyList = null,
        precisionMap = {},
        errorCode = null,
        errorParams = [],
        lastActionTime = 0;

  CurrencySearchState.startSearch(
    CurrencySearchState currencySearchState,
  )   : loading = true,
        currencyList = currencySearchState.currencyList,
        precisionMap = currencySearchState.precisionMap,
        errorCode = currencySearchState.errorCode,
        errorParams = currencySearchState.errorParams,
        lastActionTime = currencySearchState.lastActionTime;

  CurrencySearchState.finishSearch(
    this.currencyList,
    this.lastActionTime,
  )   : loading = false,
        precisionMap = {for (var e in currencyList ?? <Currency>[]) e.isoCcy: e.precision},
        errorCode = null,
        errorParams = [];

  CurrencySearchState.failSearch(
    CurrencySearchState currencySearchState,
    this.errorCode,
    this.errorParams,
    this.lastActionTime,
  )   : loading = false,
        currencyList = currencySearchState.currencyList,
        precisionMap = currencySearchState.precisionMap;
}
