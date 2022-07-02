import '../../model/payment.dart';

class BaseEnrichmentRequestSearchEvent {
}

class EnrichmentRequestSearchEvent extends BaseEnrichmentRequestSearchEvent {
  final String siteCode;
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
  final int offSet;
  final int pageSize;

  EnrichmentRequestSearchEvent({
    required this.siteCode,
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
    required this.offSet,
    required this.pageSize,
  });
}

class EnrichmentRequestRefreshEvent extends BaseEnrichmentRequestSearchEvent {
  final bool forceRefresh;
  final String? refreshSuccessMessage;

  EnrichmentRequestRefreshEvent({
    this.forceRefresh = true,
    this.refreshSuccessMessage,
  });
}

class EnrichmentRequestResetEvent extends BaseEnrichmentRequestSearchEvent {
  final String? siteCode;

  EnrichmentRequestResetEvent(this.siteCode);
}
