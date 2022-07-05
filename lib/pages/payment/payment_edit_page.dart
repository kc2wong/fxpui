import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/account_bloc.dart';
import '../../bloc/currency_bloc.dart';
import '../../bloc/enrichment_request_bloc.dart';
import '../../bloc/state/account_state.dart';
import '../../bloc/state/enrichment_request_state.dart';
import '../../bloc/system_bloc.dart';
import '../../bloc/site_bloc.dart';
import '../../localization/language.dart';
import '../../model/client.dart';
import '../../model/constant.dart';
import '../../model/currency.dart';
import '../../model/payment.dart';
import '../../model/system.dart';
import '../../pages/payment/utils.dart';
import '../../util/logger.dart';
import '../../widget/base_widget.dart';
import '../../widget/button.dart';
import '../../widget/input_date.dart';
import '../../widget/input_dropdown.dart';
import '../../widget/input_group.dart';
import '../../widget/input_number.dart';
import '../../widget/input_radio.dart';
import '../../widget/input_text.dart';

import 'single_payment_page.dart';

typedef CreateEnrichmentAction = void Function(Payment payment, String? fxRef);
typedef UpdateEnrichmentAction = void Function(String enrichmentRequestId, Payment payment, String? fxRef);

class PaymentEditPage extends StatelessWidget {
  const PaymentEditPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Expanded(
            child: SizedBox.shrink(),
            flex: 1,
          ),
          Expanded(
            child: _PaymentEditForm(),
            flex: 9,
          ),
          const Expanded(
            child: SizedBox.shrink(),
            flex: 2,
          ),
        ],
      ),
    );
  }
}

class _PaymentEditForm extends StatefulWidget with BaseWidget {
  static const defaultPaymentRefType = 'BPH';

  _PaymentEditForm({Key? key}) : super(key: key);

  @override
  State<_PaymentEditForm> createState() => _PaymentEditFormState();
}

class _PaymentEditFormState extends State<_PaymentEditForm> with BaseWidget, SinglePaymentPage {
  static const horizontalPadding = 20.0;

  late TextEditingController _accountOneController;
  late TextEditingController _accountTwoController;
  late TextEditingController _directionController;
  late TextEditingController _creditCcyController;
  late TextEditingController _creditAmountController;
  late TextEditingController _debitCcyController;
  late TextEditingController _debitAmountController;
  late TextEditingController _instructionIdController;
  late TextEditingController _executionDateController;
  late TextEditingController _fxRefController;
  late FocusNode _accountLinkFocusNode;
  late bool _initialRender;

  @override
  void initState() {
    super.initState();
    _accountOneController = TextEditingController();
    _accountTwoController = TextEditingController();
    _directionController = TextEditingController();
    _creditCcyController = TextEditingController();
    _creditAmountController = TextEditingController();
    _debitCcyController = TextEditingController();
    _debitAmountController = TextEditingController();
    _instructionIdController = TextEditingController();
    _executionDateController = TextEditingController();
    _fxRefController = TextEditingController();
    _accountLinkFocusNode = FocusNode();
    _accountLinkFocusNode.skipTraversal = true;
    _initialRender = true;
  }

  @override
  void dispose() {
    _accountOneController.dispose();
    _accountTwoController.dispose();
    _directionController.dispose();
    _creditCcyController.dispose();
    _creditAmountController.dispose();
    _debitCcyController.dispose();
    _debitAmountController.dispose();
    _instructionIdController.dispose();
    _executionDateController.dispose();
    _fxRefController.dispose();
    _accountLinkFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final i18n = Language.of(context);

    final currencySearchBloc = BlocProvider.of<CurrencySearchBloc>(context);
    final ccyMap = {for (var e in (currencySearchBloc.state.currencyList ?? <Currency>[]).map((e) => e.isoCcy)) e: e};
    final precisionMap = currencySearchBloc.state.precisionMap;

    final enrichmentRequestBloc = BlocProvider.of<EnrichmentRequestBloc>(context);
    final enrichmentRequest = enrichmentRequestBloc.state.enrichmentRequest;

    return SizedBox(
      width: 1100,
      child: Card(
        elevation: 12,
        child: Column(
          children: [
            createHeader(
              enrichmentRequest?.status ?? EnrichmentRequestStatus.initial,
              () => enrichmentRequestBloc.clearEnrichmentRequest(),
              i18n,
              horizontalPadding,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  bottom: 16.0,
                ),
                child: Row(
                  children: [
                    // Payment Detail and Start Button
                    Expanded(
                      flex: 8,
                      child: Column(
                        children: [
                          // Payment Detail
                          Expanded(
                            child: _createPaymentDetailForm(
                              enrichmentRequest,
                              ccyMap,
                              precisionMap,
                            ),
                          ),
                          // Start / Next button
                          _createButtonBar(
                            enrichmentRequest,
                            (payment, fxRef) {
                              enrichmentRequestBloc.createEnrichmentRequest(
                                payment,
                                fxRef: fxRef,
                              );
                            },
                            (id, payment, fxRef) {
                              enrichmentRequestBloc.updateEnrichmentRequest(
                                id,
                                payment,
                                fxRef: fxRef,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // Memos
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          createCaptionDivider(
                            i18n.paymentPage.memos,
                            defaultTextStyle(),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 16.0,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: themeData.dividerColor,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _createPaymentDetailForm(
    EnrichmentRequest? enrichmentRequest,
    Map<String, String> ccyMap,
    Map<String, int> precisionMap,
  ) {
    const divider = Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Divider(
        thickness: 2,
      ),
    );

    final i18n = Language.of(context);

    final directionChoices = {
      PaymentDirection.outgoing: i18n.paymentPage.outgoing,
      PaymentDirection.incoming: i18n.paymentPage.incoming,
    };

    return BlocBuilder<EnrichmentRequestBloc, EnrichmentRequestState>(
      // Rebuild and show error when validation fails
      buildWhen: (prev, current) => prev.withError != current.withError,
      builder: (_, state) {
        final draftPayment = _initialRender ? state.draftPayment : null;
        _initialRender = false;
        return Column(
          children: [
            createCaptionDivider(
              i18n.paymentPage.paymentDetail,
              defaultTextStyle(),
            ),
            _createAccountRow(draftPayment),
            divider,
            _createDirectionRow(draftPayment, directionChoices),
            _createCcyAmountRow(draftPayment, ccyMap, precisionMap, state.draftPayment.creditAmountError, state.draftPayment.debitAmountError),
            _createPaymentRefExecDateRow(draftPayment, enrichmentRequest != null && enrichmentRequest.status != EnrichmentRequestStatus.initial),
            _createFxRefRow(draftPayment),
          ],
        );
      },
    );
  }

  Widget _createAccountRow(DraftPayment? draftPayment) {
    final i18n = Language.of(context);
    final themeData = Theme.of(context);

    final enrichmentRequestBloc = BlocProvider.of<EnrichmentRequestBloc>(context);
    final fxAccountSearchBloc = BlocProvider.of<FxAccountSearchBloc>(context);
    final systemBloc = BlocProvider.of<SystemBloc>(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<FxAccountSearchBloc, FxAccountSearchState>(
          listenWhen: (previous, current) =>
          previous.loading != current.loading || current.lastActionTime > previous.lastActionTime,
          listener: (_, state) {
            if (state.loading) {
              systemBloc.startLoading();
            } else {
              systemBloc.stopLoading();
            }
          },
        ),
      ],
      child: BlocBuilder<FxAccountSearchBloc, FxAccountSearchState>(
        buildWhen: (previous, current) => current.lastActionTime > previous.lastActionTime,
        builder: (_, state) {
          final accountList = state.accountList;
          final fxAccount1 = accountList != null && accountList.isNotEmpty ? accountList[0] : null;
          final fxAccount2 = numberOfInputAccount == 2 ? (accountList != null && accountList.length > 1 ? accountList[1] : null) : null;
          logger.d('fxAccount1 = $fxAccount1, fxAccount2 = $fxAccount1');

          final matchedExtAccountRef = (fxAccount1?.externalAccount ?? <ExternalAccountRef>[])
              .where((element) => element.ref == _accountOneController.text)
              .toList(growable: false);

          final accountOneRow = Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 6,
                child: InputText(
                  mandatory: true,
                  initialValue: draftPayment?.accountRef1,
                  controller: _accountOneController,
                  label: i18n.paymentPage.account1,
                  labelSuffix: matchedExtAccountRef.isEmpty ? null : '[${matchedExtAccountRef[0].refType}]',
                  helpTextColor: themeData.errorColor,
                  tooltip: 'Enter 00001047380 to simulate valid account ref',
                  tooltipPosition: TooltipPosition.above,
                  reserveHelperTextSpace: true,
                  helperText: i18n.paymentPage.accountAlert(fxAccount1?.alertMessage),
                  onChanged: (newAccountOneRef) => enrichmentRequestBloc.draftEnrichmentRequest(accountRef1: newAccountOneRef ?? ''),
                  onEditCompleted: (value) => fxAccountSearchBloc.searchFxAccount(
                    extAccountRef1: value,
                    extAccountRef2: _accountTwoController.text,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: fxAccount1?.clientId != null
                    ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8 + BaseWidget.helperTextAreaHeight),
                  child: InkWell(
                    child: Text(
                      fxAccount1!.clientId,
                      style: defaultTextStyle(
                        color: themeData.primaryColor,
                      ),
                    ),
                    onTap: () => fxAccountSearchBloc.selectFxAccount(fxAccount1),
                    focusNode: _accountLinkFocusNode,
                    hoverColor: Colors.transparent,
                  ),
                )
                    : BaseWidget.filler,
              ),
              const Expanded(flex: 1, child: BaseWidget.filler),
              Expanded(
                flex: 15,
                child: fxAccount1?.name != null
                    ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8 + BaseWidget.helperTextAreaHeight),
                  child: Text(
                    i18n.paymentPage.accountName(fxAccount1!.name),
                  ),
                )
                    : BaseWidget.filler,
              )
            ],
          );

          final accountTwoRow = numberOfInputAccount == 1
              ? const SizedBox.shrink()
              : Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 6,
                child: InputText(
                  initialValue: draftPayment?.accountRef2,
                  controller: _accountTwoController,
                  label: i18n.paymentPage.account2,
                  labelSuffix: matchedExtAccountRef.isEmpty && matchedExtAccountRef.length > 1 ? null : '[${matchedExtAccountRef[1].refType}]',
                  helpTextColor: themeData.errorColor,
                  reserveHelperTextSpace: true,
                  helperText: i18n.paymentPage.accountAlert(fxAccount2?.alertMessage),
                  onChanged: (newAccountTwoRef) =>
                      enrichmentRequestBloc.draftEnrichmentRequest(accountRef2: newAccountTwoRef ?? ''),
                  onEditCompleted: (value) => fxAccountSearchBloc.searchFxAccount(
                    extAccountRef1: _accountTwoController.text,
                    extAccountRef2: value,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: fxAccount1?.clientId != null
                    ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8 + BaseWidget.helperTextAreaHeight),
                  child: InkWell(
                    child: Text(
                      fxAccount2!.clientId,
                      style: defaultTextStyle(
                        color: themeData.primaryColor,
                      ),
                    ),
                    onTap: () => {},
                    hoverColor: Colors.transparent,
                  ),
                )
                    : BaseWidget.filler,
              ),
              const Expanded(flex: 1, child: BaseWidget.filler),
              Expanded(
                flex: 15,
                child: fxAccount2?.name != null
                    ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8 + BaseWidget.helperTextAreaHeight),
                  child: Text(
                    i18n.paymentPage.accountName(fxAccount2!.name),
                  ),
                )
                    : BaseWidget.filler,
              )
            ],
          );

          return Column(
            children: [
              accountOneRow,
              accountTwoRow,
            ],
          );
        },
      ),
    );
  }

  Widget _createDirectionRow(DraftPayment? draftPayment, Map<PaymentDirection, String> directionChoices) {
    final i18n = Language.of(context);
    final enrichmentRequestBloc = BlocProvider.of<EnrichmentRequestBloc>(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 8,
          child: InputRadio<PaymentDirection>(
            initialValue: draftPayment?.direction,
            controller: _directionController,
            label: i18n.paymentPage.direction,
            choices: directionChoices,
            mandatory: true,
            horizontal: true,
            onChanged: (newDirection) => enrichmentRequestBloc.draftEnrichmentRequest(direction: newDirection),
          ),
        ),
        const Expanded(flex: 17, child: BaseWidget.filler),
      ],
    );
  }

  Widget _createCcyAmountRow(DraftPayment? draftPayment, Map<String, String> ccyMap, Map<String, int> precisionMap, String? creditAmountError, String? debitAmountError) {
    final i18n = Language.of(context);
    final themeData = Theme.of(context);

    final enrichmentRequestBloc = BlocProvider.of<EnrichmentRequestBloc>(context);

    final creditAmountErrorInfo = creditAmountError?.split(',');
    final debitAmountErrorInfo = debitAmountError?.split(',');

    final creditCcy = draftPayment?.creditCcy;
    final debitCcy = draftPayment?.debitCcy;

    return _addBottomPadding(
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 12,
            child: InputGroup(
              label: i18n.paymentPage.bankSell,
              mandatory: true,
              tooltip: 'Enter amount greater than 100,000 to simulate client side validation failure',
              tooltipPosition: TooltipPosition.above,
              backgroundColor: themeData.cardColor,
              widgets: [
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Padding(
                        padding: EdgeInsets.zero,
                        child: InputDropdown<String>(
                          initialValue: creditCcy != null ? [creditCcy] : null,
                          controller: _creditCcyController,
                          mandatory: true,
                          showSearchBox: true,
                          choices: ccyMap,
                          hint: i18n.ccy,
                          onChanged: (newCreditCcy) => setState(() {
                            enrichmentRequestBloc.draftEnrichmentRequest(creditCcy: newCreditCcy[0]);
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.zero,
                        child: InputNumber(
                          initialValue: draftPayment?.creditAmount,
                          controller: _creditAmountController,
                          hint: i18n.amount,
                          numberOfDecimal: precisionMap[creditCcy] ?? 0,
                          allowNegative: false,
                          onChanged: (newCreditAmount) {
                            _debitAmountController.clear();
                            setState(() {
                              enrichmentRequestBloc.draftEnrichmentRequestAmount(creditAmount: newCreditAmount);
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                )
              ],
              reserveHelperTextSpace: true,
              errorText: creditAmountErrorInfo != null
                  ? i18n.getErrorMessage(creditAmountErrorInfo.first, creditAmountErrorInfo.sublist(1))
                  : null,
            ),
          ),
          const Expanded(flex: 1, child: BaseWidget.filler),
          Expanded(
            flex: 12,
            child: InputGroup(
              label: i18n.paymentPage.bankBuy,
              mandatory: true,
              tooltip: 'Enter amount greater than 100,000 to simulate client side validation failure',
              tooltipPosition: TooltipPosition.above,
              backgroundColor: themeData.cardColor,
              widgets: [
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Padding(
                        padding: EdgeInsets.zero,
                        child: InputDropdown<String>(
                          initialValue: debitCcy != null ? [debitCcy] : null,
                          controller: _debitCcyController,
                          mandatory: true,
                          showSearchBox: true,
                          choices: ccyMap,
                          hint: i18n.ccy,
                          onChanged: (newDebitCcy) => setState(() {
                            enrichmentRequestBloc.draftEnrichmentRequest(debitCcy: newDebitCcy[0]);
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.zero,
                        child: InputNumber(
                          initialValue: draftPayment?.debitAmount,
                          controller: _debitAmountController,
                          hint: i18n.amount,
                          numberOfDecimal: precisionMap[debitCcy] ?? 0,
                          allowNegative: false,
                          onChanged: (newDebitAmount) {
                            _creditAmountController.clear();
                            setState(() {
                              enrichmentRequestBloc.draftEnrichmentRequestAmount(debitAmount: newDebitAmount);
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                )
              ],
              reserveHelperTextSpace: true,
              errorText: debitAmountErrorInfo != null
                  ? i18n.getErrorMessage(debitAmountErrorInfo.first, debitAmountErrorInfo.sublist(1))
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _createPaymentRefExecDateRow(DraftPayment? draftPayment, bool readOnly) {
    final i18n = Language.of(context);
    final themeData = Theme.of(context);
    final enrichmentRequestBloc = BlocProvider.of<EnrichmentRequestBloc>(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 12,
          child: InputText(
            initialValue: draftPayment?.paymentRef,
            controller: _instructionIdController,
            label: i18n.paymentPage.instructionId,
            prefixText: draftPayment?.paymentRefType ?? _PaymentEditForm.defaultPaymentRefType,
            enabled: !readOnly,
            reserveHelperTextSpace: true,
            onChanged: (newPaymentRef) => enrichmentRequestBloc.draftEnrichmentRequest(paymentRef: newPaymentRef),
          ),
        ),
        const Expanded(flex: 1, child: BaseWidget.filler),
        Expanded(
          flex: 6,
          child: InputDate(
            initialValue: draftPayment?.executeDate ?? DateTime.now(),
            enabled: false,
            controller: _executionDateController,
            label: i18n.paymentPage.executeDate,
            helpTextColor: themeData.errorColor,
            reserveHelperTextSpace: true,
          ),
        ),
        const Expanded(
          flex: 6,
          child: BaseWidget.filler,
        ),
      ],
    );
  }

  Widget _createFxRefRow(DraftPayment? draftPayment) {
    final i18n = Language.of(context);
    final enrichmentRequestBloc = BlocProvider.of<EnrichmentRequestBloc>(context);
    final systemBloc = BlocProvider.of<SystemBloc>(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 6,
          child: InputText(
            initialValue: draftPayment?.fxRef,
            controller: _fxRefController,
            label: i18n.paymentPage.fxRef,
            tooltip: 'Enter a fxRef to simulate server side validation failure',
            reserveHelperTextSpace: true,
            onChanged: (newFxRef) => setState(() {
              enrichmentRequestBloc.draftEnrichmentRequest(fxRef: newFxRef);
            }),
          ),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 13.5),
            child: Button(
              text: i18n.paymentPage.populate,
              buttonType: ButtonType.textOnly,
              icon: const Icon(
                Icons.upload_file,
                size: 18,
              ),
              enabled: _fxRefController.text.isNotEmpty,
              onTap: () => systemBloc.showToast('Populate Deal ${_fxRefController.text}', ToastType.info),
            ),
          ),
        ),
        const Expanded(flex: 15, child: BaseWidget.filler),
      ],
    );
  }

  Widget _createButtonBar(
    EnrichmentRequest? enrichmentRequest,
    CreateEnrichmentAction createEnrichmentAction,
    UpdateEnrichmentAction updateEnrichmentAction,
  ) {
    final i18n = Language.of(context);
    final isCreate = enrichmentRequest == null || enrichmentRequest.status == EnrichmentRequestStatus.initial;

    final startButton = BlocBuilder<EnrichmentRequestBloc, EnrichmentRequestState>(
      buildWhen: (previous, current) => previous.draftPayment.canStart() != current.draftPayment.canStart(),
      builder: (ctx, state) {
        return Button(
          text: isCreate ? i18n.paymentPage.start : i18n.next,
          buttonType: ButtonType.primary,
          icon: Icon(isCreate ? Icons.check : Icons.arrow_forward),
          enabled: state.draftPayment.canStart(),
          onTap: () {
            final siteSearchBloc = ctx.read<SiteSearchBloc>();
            final fxRef = _fxRefController.text.trim().isEmpty ? null : _fxRefController.text.trim();
            final Payment newPayment = Payment(
              siteCode: siteSearchBloc.state.selectedSite!.siteCode,
              direction:
                  _directionController.text == i18n.paymentPage.outgoing ? PaymentDirection.outgoing : PaymentDirection.incoming,
              debitCcy: _debitCcyController.text,
              debitAmount: double.tryParse(_debitAmountController.text.replaceAll(',', '')),
              creditCcy: _creditCcyController.text,
              creditAmount: double.tryParse(_creditAmountController.text.replaceAll(',', '')),
              accountRefs: [_accountOneController.text, _accountTwoController.text],
              paymentRefType: _instructionIdController.text.isNotEmpty ? 'BUI' : _PaymentEditForm.defaultPaymentRefType,
              paymentRef: _instructionIdController.text,
              executeDate: dateFormat.parse(_executionDateController.text),
            );

            isCreate
                ? createEnrichmentAction(
                    newPayment,
                    fxRef,
                  )
                : updateEnrichmentAction(
                    enrichmentRequest.id,
                    newPayment,
                    fxRef,
                  );
          },
        );
      },
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        startButton,
      ],
    );
  }

  Widget _addBottomPadding(
    Widget widget, {
    double bottomPadding = 8,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: widget,
    );
  }
}
