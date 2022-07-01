import 'package:flutter_bloc/flutter_bloc.dart';

import '../service/currency.dart';
import '../model/exception.dart';
import '../util/logger.dart';
import 'event/currency_event.dart';
import 'state/currency_state.dart';

class CurrencySearchBloc extends Bloc<CurrencySearchEvent, CurrencySearchState> {
  final CurrencySearchService _currencyService;

  CurrencySearchBloc(this._currencyService) : super(CurrencySearchState.initial(),) {
    on<CurrencySearchEvent>(_handleCurrencySearchEvent);
  }

  bool withData({String? siteCode}) {
    logger.d('CurrencySearchBloc.withData() = ${state.lastActionTime > 0}');
    return state.lastActionTime > 0;
  }

  void listCurrency({String? siteCode}) {
    add(
      CurrencySearchEvent(siteCode),
    );
  }

  Future<void> _handleCurrencySearchEvent(CurrencySearchEvent event, Emitter emit) async {
    logger.i('event = $event');

    try {
      emit(CurrencySearchState.startSearch(state));

      final searchResult = await _currencyService.listCurrency(
      );
      searchResult.sort((c1, c2) => c1.isoCcy.compareTo(c2.isoCcy));

      await Future.delayed(const Duration(seconds: 1));

      emit(CurrencySearchState.finishSearch(
        searchResult,
        DateTime.now().microsecondsSinceEpoch,
      ));
    } on ApplicationException catch (ae) {
      emit(CurrencySearchState.failSearch(state, ae.errorCode, ae.errorParams, DateTime.now().microsecondsSinceEpoch,));
    } catch (error) {
      emit(CurrencySearchState.failSearch(state, genericErrorCode, [], DateTime.now().microsecondsSinceEpoch,));
    }
  }
}
