import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/deal.dart';
import '../model/exception.dart';
import '../model/payment.dart';
import '../service/payment.dart';
import '../util/logger.dart';
import '../util/date_util.dart';
import '../util/string_util.dart';
import 'event/enrichment_request_event.dart';
import 'state/enrichment_request_state.dart';

final potentialMatchedDeals = List<PotentialMatchedDeal>.generate(
    7,
    (e) => PotentialMatchedDeal()
      ..fxRef = 'D06832$e'
      ..fxd = 'D06832$e'
      ..valueDate = currentDate()
      ..dealCcy = 'EUR'
      ..dealAmount = 12345.67
      ..contraCcy = 'USD'
      ..contraAmount = 15000.00
      ..remainingCcy = 'EUR'
      ..remainingAmount = 12345.67).toList(growable: false);

final autoQuoteInfoList = [
  AutoQuoteInfo(
    productCode: 'PROD_LIVE',
    productName: 'Product (Live)',
    defaultValueDate: currentDate(),
    allowNullValueDate: false,
  )
];

class EnrichmentRequestBloc extends Bloc<BaseEnrichmentRequestEvent, EnrichmentRequestState> {
  final PaymentSearchService _paymentSearchService;

  EnrichmentRequestBloc(this._paymentSearchService) : super(EnrichmentRequestState.initial()) {
    on<InitializeEnrichmentRequestEvent>(_handleInitializeEnrichmentRequestEvent);
    on<ClearEnrichmentRequestEvent>(_handleClearEnrichmentRequestEvent);
    on<CreateEnrichmentRequestEvent>(_handleCreateEnrichmentRequestEvent);
    on<EditEnrichmentRequestEvent>(_handleEditEnrichmentRequestEvent);
    on<UpdateEnrichmentRequestEvent>(_handleUpdateEnrichmentRequestEvent);
    on<DraftEnrichmentRequestEvent>(_handleDraftEnrichmentRequestEvent);
    on<CancelEnrichmentRequestEvent>(_handleCancelEnrichmentRequestEvent);
    on<SubmitEnrichmentRequestEvent>(_handleSubmitEnrichmentRequestEvent);
    on<GetEnrichmentRequestEvent>(_handleGetEnrichmentRequestEvent);
  }

  void initializeEnrichmentRequest(String siteCode, int numOfAccountRequired) {
    add(
      InitializeEnrichmentRequestEvent(siteCode, numOfAccountRequired),
    );
  }

  void clearEnrichmentRequest() {
    add(
      ClearEnrichmentRequestEvent(),
    );
  }

  void createEnrichmentRequest(
    Payment payment, {
    String? fxRef,
  }) {
    add(
      CreateEnrichmentRequestEvent(payment, fxRef),
    );
  }

  void getEnrichmentRequest(
    String id,
  ) {
    add(
      GetEnrichmentRequestEvent(id),
    );
  }

  void editEnrichmentRequest() {
    final id = state.enrichmentRequest!.id;
    final payment = state.enrichmentRequest!.payment;
    final fxRef = state.enrichmentRequest!.fxRef;
    add(
      EditEnrichmentRequestEvent(id, payment, fxRef),
    );
  }

  void draftEnrichmentRequest({
    String? paymentRef,
    String? accountRef1,
    String? accountRef2,
    PaymentDirection? direction,
    String? creditCcy,
    // double? creditAmount,
    String? debitCcy,
    // double? debitAmount,
    String? fxRef,
  }) {
    add(
      DraftEnrichmentRequestEvent(
        accountRef1: accountRef1,
        accountRef2: accountRef2,
        direction: direction,
        creditCcy: isNullOrEmpty(creditCcy) ? null : creditCcy,
        debitCcy: isNullOrEmpty(debitCcy) ? null : debitCcy,
        paymentRef: isNullOrEmpty(paymentRef) ? null : paymentRef,
        fxRef: isNullOrEmpty(fxRef) ? null : fxRef,
        updateAmount: false,
      ),
    );
  }

  void draftEnrichmentRequestAmount({
    double? creditAmount,
    double? debitAmount,
  }) {
    add(
      DraftEnrichmentRequestEvent(
        creditAmount: creditAmount,
        debitAmount: debitAmount,
        updateAmount: true,
      ),
    );
  }

  void updateEnrichmentRequest(
    String id,
    Payment payment, {
    String? fxRef,
  }) {
    add(
      UpdateEnrichmentRequestEvent(id, payment, fxRef),
    );
  }

  void cancelEnrichmentRequest() {
    final id = state.enrichmentRequest!.id;
    final payment = state.enrichmentRequest!.payment;
    add(
      CancelEnrichmentRequestEvent(id, payment),
    );
  }

  void submitEnrichmentRequest(String id, String? fxd, String? productCode, DateTime? valueDate) {
    add(
      SubmitEnrichmentRequestEvent(id, fxd, productCode, valueDate),
    );
  }

  Future<void> _handleInitializeEnrichmentRequestEvent(InitializeEnrichmentRequestEvent event, Emitter emit) async {
    emit(
      EnrichmentRequestState.initializeEnrichmentRequest(event.numOfAccountRequired)
    );
  }

  Future<void> _handleClearEnrichmentRequestEvent(ClearEnrichmentRequestEvent event, Emitter emit) async {
    emit(
        EnrichmentRequestState.clearEnrichmentRequest()
    );
  }

  Future<void> _handleCreateEnrichmentRequestEvent(CreateEnrichmentRequestEvent event, Emitter emit) async {
    final originalStatus = state.transactionStatus;

    // Client Side validation
    final errorMap = _validatePayment(event.payment);
    if (errorMap.isNotEmpty) {
      final newDraftPayment = DraftPayment.withValidationFailure(
        state.draftPayment,
        creditAmountError: errorMap['creditAmount'],
        debitAmountError: errorMap['debitAmount'],
      );
      emit(
          EnrichmentRequestState(
            transactionStatus: originalStatus,
            enrichmentRequest: state.enrichmentRequest,
            draftPayment: newDraftPayment,
            potentialMatchedDealList: state.potentialMatchedDealList,
            autoQuoteInfoList: state.autoQuoteInfoList,
            errorCode: state.errorCode,
            errorParams: state.errorParams,
            withError: true,
          )
      );
      return;
    }

    emit(
        EnrichmentRequestState.startCreate(state.draftPayment)
    );

    // Call backend service to create the request
    await Future.delayed(const Duration(seconds: 1));

    final emptyPaymentRef = event.payment.paymentRef == null || event.payment.paymentRef!.isEmpty;
    final Payment newPayment = Payment(
      siteCode: event.payment.siteCode,
      accountRefs: event.payment.accountRefs,
      direction: event.payment.direction,
      creditCcy: event.payment.creditCcy,
      creditAmount: event.payment.creditAmount,
      debitCcy: event.payment.debitCcy,
      debitAmount: event.payment.debitAmount,
      executeDate: currentDate(),
      paymentRefType: emptyPaymentRef ? 'BPH' : 'BUI',
      // do not generate the paymentRef when simulate error case
      paymentRef: event.fxRef == null ? (emptyPaymentRef ? (DateTime.now().millisecondsSinceEpoch / 1000).round().toString() : event.payment.paymentRef) : null,
    );

    final enrichmentRequest = EnrichmentRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      payment: newPayment,
      status: EnrichmentRequestStatus.started,
    );

    if (event.fxRef != null) {
      // simulate an error when fxRef is specified
      try {
        await _paymentSearchService.createPayment(newPayment, event.fxRef);
        emit(
            EnrichmentRequestState.finishCreate(enrichmentRequest, potentialMatchedDeals, autoQuoteInfoList)
        );
      } on ApplicationException catch (ae) {
        emit(
            EnrichmentRequestState(
              transactionStatus: originalStatus,
              enrichmentRequest: state.enrichmentRequest,
              draftPayment: state.draftPayment,
              potentialMatchedDealList: [],
              autoQuoteInfoList: [],
              errorCode: ae.errorCode,
              errorParams: [event.fxRef!],
            )
        );
      }
    }
    else {
      emit(
          EnrichmentRequestState.finishCreate(enrichmentRequest, potentialMatchedDeals, autoQuoteInfoList)
      );
    }
  }

  Future<void> _handleUpdateEnrichmentRequestEvent(UpdateEnrichmentRequestEvent event, Emitter emit) async {
    final originalStatus = state.transactionStatus;

    final errorMap = _validatePayment(event.payment);
    if (errorMap.isNotEmpty) {
      final newDraftPayment = DraftPayment.withValidationFailure(
        state.draftPayment,
        creditAmountError: errorMap['creditAmount'],
        debitAmountError: errorMap['debitAmount'],
      );
      emit(
          EnrichmentRequestState(
            transactionStatus: originalStatus,
            enrichmentRequest: state.enrichmentRequest,
            draftPayment: newDraftPayment,
            potentialMatchedDealList: state.potentialMatchedDealList,
            autoQuoteInfoList: state.autoQuoteInfoList,
            errorCode: state.errorCode,
            errorParams: state.errorParams,
            withError: true,
          )
      );
      return;
    }

    emit(
        EnrichmentRequestState.startUpdate(state.enrichmentRequest!, state.draftPayment)
    );

    // Call backend service to update the request
    await Future.delayed(const Duration(seconds: 1));

    final payment = state.enrichmentRequest!.payment;
    final Payment newPayment = Payment.fromExistingWithDelta(payment,
      siteCode: event.payment.siteCode,
      accountRefs: event.payment.accountRefs,
      direction: event.payment.direction,
      creditCcy: event.payment.creditCcy,
      creditAmount: event.payment.creditAmount,
      debitCcy: event.payment.debitCcy,
      debitAmount: event.payment.debitAmount,
    );

    final enrichmentRequest = EnrichmentRequest.fromExisting(
      state.enrichmentRequest!,
      payment: newPayment,
      status: EnrichmentRequestStatus.started,
    );

    if (event.fxRef != null) {
      // simulate an error when fxRef is specified
      emit(
          EnrichmentRequestState(
            transactionStatus: originalStatus,
            enrichmentRequest: state.enrichmentRequest,
            draftPayment: state.draftPayment,
            potentialMatchedDealList: [],
            autoQuoteInfoList: [],
            errorCode: 'ERR_INVALID_FX_REF',
            errorParams: [event.fxRef!],
          )
      );
    }
    else {
      emit(
          EnrichmentRequestState.finishUpdate(enrichmentRequest, potentialMatchedDeals, autoQuoteInfoList)
      );
    }
  }

  Future<void> _handleDraftEnrichmentRequestEvent(DraftEnrichmentRequestEvent event, Emitter emit) async {

    final oldDraftPayment = state.draftPayment;

    final newDraftPayment = DraftPayment(
      numOfAccountRequired: oldDraftPayment.numOfAccountRequired,
      accountRef1: event.accountRef1 != null ? (event.accountRef1!.isNotEmpty ? event.accountRef1 : null) : oldDraftPayment.accountRef1,
      accountRef2: event.accountRef2 != null ? (event.accountRef2!.isNotEmpty ? event.accountRef2 : null) : oldDraftPayment.accountRef2,
      direction: event.direction ?? oldDraftPayment.direction,
      creditCcy: event.creditCcy ?? oldDraftPayment.creditCcy,
      creditAmount: event.updateAmount ? event.creditAmount : oldDraftPayment.creditAmount,
      debitCcy: event.debitCcy ?? oldDraftPayment.debitCcy,
      debitAmount: event.updateAmount ? event.debitAmount : oldDraftPayment.debitAmount,
      paymentRef: event.paymentRef ?? oldDraftPayment.paymentRef,
      paymentRefType: oldDraftPayment.paymentRefType,
      executeDate: oldDraftPayment.executeDate,
      fxRef: event.fxRef ?? oldDraftPayment.fxRef,
    );

    emit(EnrichmentRequestState(
      enrichmentRequest: state.enrichmentRequest,
      draftPayment: newDraftPayment,
      potentialMatchedDealList: state.potentialMatchedDealList,
      autoQuoteInfoList: state.autoQuoteInfoList,
      transactionStatus: state.transactionStatus,
      dealToMatch: state.dealToMatch,
      autoQuoteInfo: state.autoQuoteInfo,
      errorCode: null,
      errorParams: [],
      withError: false,
    ));
  }

  Future<void> _handleGetEnrichmentRequestEvent(GetEnrichmentRequestEvent event, Emitter emit) async {

    emit(
        EnrichmentRequestState.startGetOne()
    );

    final searchResult = await _paymentSearchService.searchEnrichmentRequest(
      offSet: 0,
      pageSize: 50,
    );
    final enrichmentRequest = searchResult.elements.firstWhere((element) => element.id == event.id);

    await Future.delayed(const Duration(seconds: 1));

    emit(
        EnrichmentRequestState.finishGetOne(enrichmentRequest, const [], const [])
    );
  }

  Future<void> _handleEditEnrichmentRequestEvent(EditEnrichmentRequestEvent event, Emitter emit) async {

    final enrichmentRequest = EnrichmentRequest.fromExisting(
      state.enrichmentRequest!,
      payment: event.payment,
      status: EnrichmentRequestStatus.started,
    );

    final payment = event.payment;
    final draftPayment = DraftPayment(
      numOfAccountRequired: payment.accountRefs.length,
      accountRef1: payment.accountRefs.isNotEmpty ? payment.accountRefs[0] : null,
      accountRef2: payment.accountRefs.length > 1 ? payment.accountRefs[1] : null,
      direction: payment.direction,
      creditCcy: payment.creditCcy,
      creditAmount: payment.creditAmount,
      debitCcy: payment.debitCcy,
      debitAmount: payment.debitAmount,
      paymentRef: payment.paymentRef,
      paymentRefType: payment.paymentRefType,
      executeDate: payment.executeDate,
      fxRef: enrichmentRequest.fxRef,
    );

    emit(
        EnrichmentRequestState.edit(enrichmentRequest, draftPayment)
    );
  }

  Future<void> _handleCancelEnrichmentRequestEvent(CancelEnrichmentRequestEvent event, Emitter emit) async {

    emit(
        EnrichmentRequestState.startCancel(state.enrichmentRequest!)
    );

    await Future.delayed(const Duration(seconds: 1));
    // enrichmentRequest.status = EnrichmentRequestStatus.cancelled;
    final enrichmentRequest = EnrichmentRequest.fromExisting(
      state.enrichmentRequest!,
      payment: event.payment,
      status: EnrichmentRequestStatus.cancelled,
    );

    emit(
        EnrichmentRequestState.finishCancel(enrichmentRequest)
    );
  }

  Future<void> _handleSubmitEnrichmentRequestEvent(SubmitEnrichmentRequestEvent event, Emitter emit) async {

    final dealToMatch = event.fxd == null ? null : state.potentialMatchedDealList.firstWhere((element) => element.fxd == event.fxd);
    final autoQuoteInfo = event.productCode != null ? state.autoQuoteInfoList.firstWhere((element) => element.productCode == event.productCode) : null;
    logger.d('_handleSubmitEnrichmentRequestEvent, event.fxd = ${event.fxd} dealToMatch = $dealToMatch');

    emit(EnrichmentRequestState.startSubmit(
      // enrichmentRequest,
      state.enrichmentRequest!,
      dealToMatch,
      autoQuoteInfo,
    ));

    // Call backend service to update the request
    await Future.delayed(const Duration(seconds: 1));
    // enrichmentRequest.status = EnrichmentRequestStatus.paired;
    final enrichmentRequest = EnrichmentRequest.fromExisting(
      state.enrichmentRequest!,
      status: EnrichmentRequestStatus.paired,
    );

    emit(EnrichmentRequestState.finishSubmit(
      enrichmentRequest,
      state.dealToMatch,
      state.autoQuoteInfo,
    ));
  }

  Map<String, String> _validatePayment(Payment draftPayment)  {
    final errorMap = <String, String>{};
    if ((draftPayment.creditAmount ?? 0) > 10000) {
      errorMap['creditAmount'] = 'INVALID_CREDIT_DEBIT_AMOUNT,10000';
    }
    if ((draftPayment.debitAmount ?? 0) > 10000) {
      errorMap['debitAmount'] = 'INVALID_DEBIT_DEBIT_AMOUNT,10000';
    }
    return errorMap;
  }
}
