import '../../model/payment.dart';

abstract class BaseEnrichmentRequestEvent {
  BaseEnrichmentRequestEvent();
}

class InitializeEnrichmentRequestEvent extends BaseEnrichmentRequestEvent {
  final String siteCode;
  final int numOfAccountRequired;

  InitializeEnrichmentRequestEvent(
    this.siteCode,
    this.numOfAccountRequired,
  );
}

class ClearEnrichmentRequestEvent extends BaseEnrichmentRequestEvent {
  ClearEnrichmentRequestEvent();
}

class CreateEnrichmentRequestEvent extends BaseEnrichmentRequestEvent {
  final Payment payment;
  String? fxRef;

  CreateEnrichmentRequestEvent(
    this.payment,
    this.fxRef,
  );
}

class GetEnrichmentRequestEvent extends BaseEnrichmentRequestEvent {
  final String id;

  GetEnrichmentRequestEvent(
    this.id,
  );
}

class EditEnrichmentRequestEvent extends BaseEnrichmentRequestEvent {
  final String id;
  final Payment payment;
  String? fxRef;

  EditEnrichmentRequestEvent(
    this.id,
    this.payment,
    this.fxRef,
  );
}

class UpdateEnrichmentRequestEvent extends BaseEnrichmentRequestEvent {
  final String id;
  final Payment payment;
  String? fxRef;

  UpdateEnrichmentRequestEvent(
    this.id,
    this.payment,
    this.fxRef,
  );
}

// Update the payment stored in state only
class DraftEnrichmentRequestEvent extends BaseEnrichmentRequestEvent {
  String? paymentRef;
  String? accountRef1;
  String? accountRef2;
  PaymentDirection? direction;
  String? creditCcy;
  double? creditAmount;
  String? debitCcy;
  double? debitAmount;
  String? fxRef;
  bool updateAmount;

  DraftEnrichmentRequestEvent({
    this.paymentRef,
    this.accountRef1,
    this.accountRef2,
    this.direction,
    this.creditCcy,
    this.creditAmount,
    this.debitCcy,
    this.debitAmount,
    this.fxRef,
    required this.updateAmount,
  });
}

class CancelEnrichmentRequestEvent extends BaseEnrichmentRequestEvent {
  final String id;
  final Payment payment;

  CancelEnrichmentRequestEvent(
    this.id,
    this.payment,
  );
}

class SubmitEnrichmentRequestEvent extends BaseEnrichmentRequestEvent {
  final String id;
  final String? fxd;
  final String? productCode;
  final DateTime? valueDate;

  SubmitEnrichmentRequestEvent(
    this.id,
    this.fxd,
    this.productCode,
    this.valueDate,
  );
}
