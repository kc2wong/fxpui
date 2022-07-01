import '../../model/common.dart';
import '../../model/payment.dart';

class EnrichmentRequestSearchState {
  final String? siteCode;
  // Search criteria
  final List<EnrichmentRequestStatus>? enrichmentRequestStatus;
  final String? instructionId;
  final String? account;
  final DateTime? executionDateFrom;
  final DateTime? executionDateTo;
  final String? initiatedBy;
  final String? creditCcy;
  final double? creditAmountFrom;
  final double? creditAmountTo;
  final String? debitCcy;
  final double? debitAmountFrom;
  final double? debitAmountTo;

  final int? offSet;
  final int? pageSize;
  final bool loading;
  final SearchResult<EnrichmentRequest>? searchResult;
  final String? errorCode;
  final List<String>? errorParams;
  final int lastActionTime;
  final DateTime? lastSuccessRefreshTime;
  final String? refreshSuccessMessage;

  EnrichmentRequestSearchState({
    this.siteCode,
    this.enrichmentRequestStatus,
    this.instructionId,
    this.account,
    this.executionDateFrom,
    this.executionDateTo,
    this.initiatedBy,
    this.creditCcy,
    this.creditAmountFrom,
    this.creditAmountTo,
    this.debitCcy,
    this.debitAmountFrom,
    this.debitAmountTo,
    this.loading = false,
    this.searchResult,
    this.errorCode,
    this.errorParams,
    this.lastActionTime = 0,
    this.lastSuccessRefreshTime,
    this.refreshSuccessMessage,
    this.offSet = 0,
    this.pageSize,
  });

  EnrichmentRequestSearchState.startLoading(EnrichmentRequestSearchState currentState)
      : enrichmentRequestStatus = currentState.enrichmentRequestStatus,
        siteCode = currentState.siteCode,
        instructionId = currentState.instructionId,
        account = currentState.account,
        executionDateFrom = currentState.executionDateFrom,
        executionDateTo = currentState.executionDateTo,
        initiatedBy = currentState.initiatedBy,
        creditCcy = currentState.creditCcy,
        creditAmountFrom = currentState.creditAmountFrom,
        creditAmountTo = currentState.creditAmountTo,
        debitCcy = currentState.debitCcy,
        debitAmountFrom = currentState.debitAmountFrom,
        debitAmountTo = currentState.debitAmountTo,
        loading = true,
        lastActionTime = currentState.lastActionTime,
        searchResult = currentState.searchResult,
        // searchResult = SearchResult.empty(offSet: currentState.offSet!, pageSize: currentState.pageSize!),
        errorCode = currentState.errorCode,
        errorParams = currentState.errorParams,
        lastSuccessRefreshTime = currentState.lastSuccessRefreshTime,
        refreshSuccessMessage = null,
        offSet = currentState.offSet,
        pageSize = currentState.pageSize;

  EnrichmentRequestSearchState.fromFailure(EnrichmentRequestSearchState currentState, this.errorCode, this.errorParams)
      : enrichmentRequestStatus = currentState.enrichmentRequestStatus,
        siteCode = currentState.siteCode,
        instructionId = currentState.instructionId,
        account = currentState.account,
        executionDateFrom = currentState.executionDateFrom,
        executionDateTo = currentState.executionDateTo,
        initiatedBy = currentState.initiatedBy,
        creditCcy = currentState.creditCcy,
        creditAmountFrom = currentState.creditAmountFrom,
        creditAmountTo = currentState.creditAmountTo,
        debitCcy = currentState.debitCcy,
        debitAmountFrom = currentState.debitAmountFrom,
        debitAmountTo = currentState.debitAmountTo,
        loading = false,
        lastActionTime = DateTime.now().microsecondsSinceEpoch,
        searchResult = currentState.searchResult,
        lastSuccessRefreshTime = currentState.lastSuccessRefreshTime,
        refreshSuccessMessage = null,
        offSet = currentState.offSet,
        pageSize = currentState.pageSize;

  // bool withData() => lastActionTime > 0;
  bool withData() => searchResult != null;
}
