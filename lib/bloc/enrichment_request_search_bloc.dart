import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/event/enrichment_request_search_event.dart';
import '../bloc/state/enrichment_request_search_state.dart';
import '../service/payment.dart';

import '../model/exception.dart';
import '../model/payment.dart';
import '../util/logger.dart';

class EnrichmentRequestSearchBloc extends Bloc<BaseEnrichmentRequestSearchEvent, EnrichmentRequestSearchState> {
  final PaymentSearchService _paymentSearchService;
  final DateTime _currentDateTime;

  EnrichmentRequestSearchBloc(
    this._paymentSearchService,
    this._currentDateTime,
  ) : super(
          EnrichmentRequestSearchState(),
        ) {
    on<EnrichmentRequestSearchEvent>(_handlePaymentSearchEvent);
    on<EnrichmentRequestRefreshEvent>(_handlePaymentRefreshEvent);
    on<EnrichmentRequestResetEvent>(_handlePaymentResetEvent);
  }

  void resetState({String? siteCode}) {
    add(
      EnrichmentRequestResetEvent(siteCode),
    );
  }

  void refreshData({
    String? refreshSuccessMessage,
    bool forceRefresh = true,
  }) {
    add(
      EnrichmentRequestRefreshEvent(
        refreshSuccessMessage: refreshSuccessMessage,
        forceRefresh: forceRefresh,
      ),
    );
  }

  void search({
    required String siteCode,
    List<EnrichmentRequestStatus>? enrichmentRequestStatus,
    String? instructionId,
    String? account,
    DateTime? executionDateFrom,
    DateTime? executionDateTo,
    String? initiatedBy,
    String? creditCcy,
    double? creditAmountFrom,
    double? creditAmountTo,
    String? debitCcy,
    double? debitAmountFrom,
    double? debitAmountTo,
    required int offSet,
    required int pageSize,
  }) {
    add(
      EnrichmentRequestSearchEvent(
        siteCode: siteCode,
        offSet: offSet,
        pageSize: pageSize,
        enrichmentRequestStatus: enrichmentRequestStatus,
        instructionId: instructionId,
        account: account,
        executionDateFrom: executionDateFrom,
        executionDateTo: executionDateTo,
        initiatedBy: initiatedBy,
        creditCcy: creditCcy,
        creditAmountFrom: creditAmountFrom,
        creditAmountTo: creditAmountTo,
        debitCcy: debitCcy,
        debitAmountFrom: debitAmountFrom,
        debitAmountTo: debitAmountTo,
      ),
    );
  }

  Future<void> _handlePaymentRefreshEvent(EnrichmentRequestRefreshEvent event, Emitter emit) async {
    if (event.forceRefresh || state.lastActionTime <= 0) {
      try {

        emit(EnrichmentRequestSearchState.startLoading(state));

        final searchResult = await _paymentSearchService.searchEnrichmentRequest(
          siteCode: state.siteCode,
          offSet: state.offSet ?? 0,
          pageSize: state.pageSize ?? 0,
          enrichmentRequestStatus: state.enrichmentRequestStatus,
          instructionId: state.instructionId,
          account: state.account,
          executionDateFrom: state.executionDateFrom,
          executionDateTo: state.executionDateTo,
          creditCcy: state.creditCcy,
          creditAmountFrom: state.creditAmountFrom,
          creditAmountTo: state.creditAmountTo,
          debitCcy: state.debitCcy,
          debitAmountFrom: state.debitAmountFrom,
          debitAmountTo: state.debitAmountTo,
        );

        await Future.delayed(const Duration(seconds: 1));

        final now = DateTime.now();
        emit(EnrichmentRequestSearchState(
          siteCode: state.siteCode,
          enrichmentRequestStatus: state.enrichmentRequestStatus,
          instructionId: state.instructionId,
          account: state.account,
          executionDateFrom: state.executionDateFrom,
          executionDateTo: state.executionDateTo,
          initiatedBy: state.initiatedBy,
          creditCcy: state.creditCcy,
          creditAmountFrom: state.creditAmountFrom,
          creditAmountTo: state.creditAmountTo,
          debitCcy: state.debitCcy,
          debitAmountFrom: state.debitAmountFrom,
          debitAmountTo: state.debitAmountTo,
          searchResult: searchResult,
          loading: false,
          lastActionTime: now.microsecondsSinceEpoch,
          lastSuccessRefreshTime: now,
          refreshSuccessMessage: event.refreshSuccessMessage,
        ));
      } on ApplicationException catch (ae) {
        logger.w('applicationException = $ae');
        emit(EnrichmentRequestSearchState.fromFailure(state, ae.errorCode, ae.errorParams));
      } catch (error) {
        logger.w('error = $error');
        emit(EnrichmentRequestSearchState.fromFailure(state, genericErrorCode, []));
      }
    }
  }

  Future<void> _handlePaymentSearchEvent(EnrichmentRequestSearchEvent event, Emitter emit) async {
    logger.i('EnrichmentRequestSearchEvent siteCode = ${event.siteCode}, executionDateFrom = ${event.executionDateFrom}');

    try {
      emit(EnrichmentRequestSearchState(
        loading: true,
        siteCode: event.siteCode,
        enrichmentRequestStatus: event.enrichmentRequestStatus,
        instructionId: event.instructionId,
        account: event.account,
        executionDateFrom: event.executionDateFrom,
        executionDateTo: event.executionDateTo,
        initiatedBy: event.initiatedBy,
        creditCcy: event.creditCcy,
        creditAmountFrom: event.creditAmountFrom,
        creditAmountTo: event.creditAmountTo,
        debitCcy: event.debitCcy,
        debitAmountFrom: event.debitAmountFrom,
        debitAmountTo: event.debitAmountTo,
        searchResult: null,
        offSet: state.offSet,
        pageSize: state.pageSize,
        lastActionTime: DateTime.now().microsecondsSinceEpoch,
        lastSuccessRefreshTime: state.lastSuccessRefreshTime,
      ));

      final searchResult = await _paymentSearchService.searchEnrichmentRequest(
        siteCode: event.siteCode,
        offSet: event.offSet,
        pageSize: event.pageSize,
        enrichmentRequestStatus: event.enrichmentRequestStatus,
        instructionId: event.instructionId,
        account: event.account,
        executionDateFrom: event.executionDateFrom,
        executionDateTo: event.executionDateTo,
        creditCcy: event.creditCcy,
        creditAmountFrom: event.creditAmountFrom,
        creditAmountTo: event.creditAmountTo,
        debitCcy: event.debitCcy,
        debitAmountFrom: event.debitAmountFrom,
        debitAmountTo: event.debitAmountTo,
      );

      await Future.delayed(const Duration(seconds: 1));

      final now = DateTime.now();
      emit(EnrichmentRequestSearchState(
        siteCode: state.siteCode,
        enrichmentRequestStatus: event.enrichmentRequestStatus,
        instructionId: event.instructionId,
        account: event.account,
        executionDateFrom: event.executionDateFrom,
        executionDateTo: event.executionDateTo,
        initiatedBy: event.initiatedBy,
        creditCcy: event.creditCcy,
        creditAmountFrom: event.creditAmountFrom,
        creditAmountTo: event.creditAmountTo,
        debitCcy: event.debitCcy,
        debitAmountFrom: event.debitAmountFrom,
        debitAmountTo: event.debitAmountTo,
        searchResult: searchResult,
        lastActionTime: now.microsecondsSinceEpoch,
        lastSuccessRefreshTime: now,
      ));
    } on ApplicationException catch (ae) {
      emit(EnrichmentRequestSearchState.fromFailure(state, ae.errorCode, ae.errorParams));
    } catch (error) {
      emit(EnrichmentRequestSearchState.fromFailure(state, genericErrorCode, []));
    }
  }

  Future<void> _handlePaymentResetEvent(EnrichmentRequestResetEvent event, Emitter emit) async {
    logger.i('event = $event');

    if (event.siteCode == null) {
      emit(EnrichmentRequestSearchState());
    }
    else {
      emit(EnrichmentRequestSearchState(
        siteCode: event.siteCode,
        executionDateFrom: DateUtils.dateOnly(_currentDateTime),
        executionDateTo: DateUtils.dateOnly(_currentDateTime),
      ));
    }
  }
}

