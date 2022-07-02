import '../../model/deal.dart';
import '../../model/payment.dart';

enum TransactionStatus {
  noTransaction,
  edit,
  startCreate,
  finishCreate,
  startUpdate,
  finishUpdate,
  startGetOne,
  finishGetOne,
  startCancel,
  finishCancel,
  startSubmit,
  finishSubmit,
}

final loadingState = [
  TransactionStatus.startCreate,
  TransactionStatus.startUpdate,
  TransactionStatus.startCancel,
  TransactionStatus.startSubmit,
  TransactionStatus.startGetOne,
];

class EnrichmentRequestState {
  final TransactionStatus transactionStatus;
  final DraftPayment draftPayment;
  final EnrichmentRequest? enrichmentRequest;
  final List<PotentialMatchedDeal> potentialMatchedDealList;
  final List<AutoQuoteInfo> autoQuoteInfoList;
  final PotentialMatchedDeal? dealToMatch;
  final AutoQuoteInfo? autoQuoteInfo;

  late final bool withError;
  final String? errorCode;
  final List<String> errorParams;
  late final int lastActionTime;

  bool isLoading() => loadingState.contains(transactionStatus);

  EnrichmentRequestState({
    required this.transactionStatus,
    this.enrichmentRequest,
    required this.draftPayment,
    required this.potentialMatchedDealList,
    required this.autoQuoteInfoList,
    this.dealToMatch,
    this.autoQuoteInfo,
    this.errorCode,
    required this.errorParams,
    bool? withError,
    int? lastActionTime,
  }) {
    this.lastActionTime = lastActionTime ?? DateTime.now().microsecondsSinceEpoch;
    this.withError = withError ?? errorCode != null;
  }

  EnrichmentRequestState.initial()
      : transactionStatus = TransactionStatus.noTransaction,
        enrichmentRequest = null,
        draftPayment = DraftPayment(),
        potentialMatchedDealList = [],
        autoQuoteInfoList = [],
        dealToMatch = null,
        autoQuoteInfo = null,
        errorCode = null,
        errorParams = [],
        withError = false,
        lastActionTime = 0;

  EnrichmentRequestState.initializeEnrichmentRequest(int numOfAccountRequired)
      // : transactionStatus = TransactionStatus.initialize,
      : transactionStatus = TransactionStatus.edit,
        enrichmentRequest = null,
        draftPayment = DraftPayment(numOfAccountRequired: numOfAccountRequired),
        errorCode = null,
        potentialMatchedDealList = [],
        autoQuoteInfoList = [],
        dealToMatch = null,
        autoQuoteInfo = null,
        errorParams = [],
        withError = false,
        lastActionTime = DateTime.now().microsecondsSinceEpoch;

  EnrichmentRequestState.clearEnrichmentRequest()
      : transactionStatus = TransactionStatus.noTransaction,
        enrichmentRequest = null,
        draftPayment = DraftPayment(),
        errorCode = null,
        potentialMatchedDealList = [],
        autoQuoteInfoList = [],
        dealToMatch = null,
        autoQuoteInfo = null,
        errorParams = [],
        withError = false,
        lastActionTime = DateTime.now().microsecondsSinceEpoch;

  EnrichmentRequestState.startCreate(this.draftPayment)
      : transactionStatus = TransactionStatus.startCreate,
        enrichmentRequest = null,
        potentialMatchedDealList = [],
        autoQuoteInfoList = [],
        dealToMatch = null,
        autoQuoteInfo = null,
        errorCode = null,
        errorParams = [],
        withError = false,
        lastActionTime = DateTime.now().microsecondsSinceEpoch;

  EnrichmentRequestState.finishCreate(this.enrichmentRequest, this.potentialMatchedDealList, this.autoQuoteInfoList)
      : transactionStatus = TransactionStatus.finishCreate,
        draftPayment = DraftPayment(),
        dealToMatch = null,
        autoQuoteInfo = null,
        errorCode = null,
        errorParams = [],
        withError = false,
        lastActionTime = DateTime.now().microsecondsSinceEpoch;

  EnrichmentRequestState.startGetOne()
      : transactionStatus = TransactionStatus.startGetOne,
        enrichmentRequest = null,
        draftPayment = DraftPayment(),
        potentialMatchedDealList = [],
        autoQuoteInfoList = [],
        dealToMatch = null,
        autoQuoteInfo = null,
        errorCode = null,
        errorParams = [],
        withError = false,
        lastActionTime = DateTime.now().microsecondsSinceEpoch;

  EnrichmentRequestState.finishGetOne(this.enrichmentRequest, this.potentialMatchedDealList, this.autoQuoteInfoList)
      : transactionStatus = TransactionStatus.finishGetOne,
        draftPayment = DraftPayment(),
        dealToMatch = null,
        autoQuoteInfo = null,
        errorCode = null,
        errorParams = [],
        withError = false,
        lastActionTime = DateTime.now().microsecondsSinceEpoch;

  EnrichmentRequestState.edit(this.enrichmentRequest, this.draftPayment)
      : transactionStatus = TransactionStatus.edit,
        potentialMatchedDealList = [],
        autoQuoteInfoList = [],
        dealToMatch = null,
        autoQuoteInfo = null,
        errorCode = null,
        errorParams = [],
        withError = false,
        lastActionTime = DateTime.now().microsecondsSinceEpoch;

  EnrichmentRequestState.startUpdate(this.enrichmentRequest, this.draftPayment)
      : transactionStatus = TransactionStatus.startUpdate,
        potentialMatchedDealList = [],
        autoQuoteInfoList = [],
        dealToMatch = null,
        autoQuoteInfo = null,
        errorCode = null,
        errorParams = [],
        withError = false,
        lastActionTime = DateTime.now().microsecondsSinceEpoch;

  EnrichmentRequestState.finishUpdate(this.enrichmentRequest, this.potentialMatchedDealList, this.autoQuoteInfoList)
      : transactionStatus = TransactionStatus.finishUpdate,
        draftPayment = DraftPayment(),
        dealToMatch = null,
        autoQuoteInfo = null,
        errorCode = null,
        errorParams = [],
        lastActionTime = DateTime.now().microsecondsSinceEpoch;

  EnrichmentRequestState.startCancel(this.enrichmentRequest)
      : transactionStatus = TransactionStatus.startCancel,
        draftPayment = DraftPayment(),
        potentialMatchedDealList = [],
        autoQuoteInfoList = [],
        dealToMatch = null,
        autoQuoteInfo = null,
        errorCode = null,
        errorParams = [],
        withError = false,
        lastActionTime = DateTime.now().microsecondsSinceEpoch;

  EnrichmentRequestState.finishCancel(this.enrichmentRequest)
      : transactionStatus = TransactionStatus.finishCancel,
        draftPayment = DraftPayment(),
        potentialMatchedDealList = [],
        autoQuoteInfoList = [],
        dealToMatch = null,
        autoQuoteInfo = null,
        errorCode = null,
        errorParams = [],
        lastActionTime = DateTime.now().microsecondsSinceEpoch;

  EnrichmentRequestState.startSubmit(this.enrichmentRequest, this.dealToMatch, this.autoQuoteInfo)
      : transactionStatus = TransactionStatus.startSubmit,
        draftPayment = DraftPayment(),
        potentialMatchedDealList = [],
        autoQuoteInfoList = [],
        errorCode = null,
        errorParams = [],
        withError = false,
        lastActionTime = DateTime.now().microsecondsSinceEpoch;

  EnrichmentRequestState.finishSubmit(this.enrichmentRequest, this.dealToMatch, this.autoQuoteInfo)
      : transactionStatus = TransactionStatus.finishSubmit,
        draftPayment = DraftPayment(),
        potentialMatchedDealList = [],
        autoQuoteInfoList = [],
        errorCode = null,
        errorParams = [],
        withError = false,
        lastActionTime = DateTime.now().microsecondsSinceEpoch;

}
