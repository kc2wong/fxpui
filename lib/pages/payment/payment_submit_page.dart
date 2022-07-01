import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'single_payment_page.dart';

import '../../bloc/currency_bloc.dart';
import '../../bloc/enrichment_request_bloc.dart';
import '../../bloc/system_bloc.dart';
import '../../localization/language.dart';
import '../../model/constant.dart';
import '../../model/deal.dart';
import '../../model/payment.dart';
import '../../model/system.dart';
import '../../util/logger.dart';
import '../../widget/base_widget.dart';
import '../../widget/button.dart';
import '../../widget/data_grid.dart';
import '../../widget/dialog.dart';
import '../../widget/input_date.dart';
import '../../widget/input_dropdown.dart';
import '../../widget/input_text.dart';

class PaymentSubmitPage extends StatelessWidget {
  const PaymentSubmitPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: const [
          Expanded(
            child: SizedBox.shrink(),
            flex: 1,
          ),
          Expanded(
            child: _PaymentDetailForm(),
            flex: 9,
          ),
          Expanded(
            child: SizedBox.shrink(),
            flex: 2,
          ),
        ],
      ),
    );
  }
}

class _PaymentDetailForm extends StatefulWidget {
  const _PaymentDetailForm({Key? key}) : super(key: key);

  @override
  State<_PaymentDetailForm> createState() => _PaymentDetailFormState();
}

class _PaymentDetailFormState extends State<_PaymentDetailForm> with BaseWidget, SinglePaymentPage, SingleTickerProviderStateMixin {
  static const horizontalPadding = 20.0;
  static const filler = SizedBox.shrink();

  late TabController _tabController;
  late TextEditingController _traderCommentController;
  late TextEditingController _productController;
  late TextEditingController _valueDateController;
  late TextEditingController _memoController;

  Pair<String, SortDirection>? sortField;

  int? _selectedPotentialMatchedDealIdx;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Refresh the tab icon
      setState(() {});
    });
    _traderCommentController = TextEditingController();
    _productController = TextEditingController();
    _valueDateController = TextEditingController();
    _memoController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _traderCommentController.dispose();
    _productController.dispose();
    _valueDateController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final i18n = Language.of(context);

    final systemBloc = BlocProvider.of<SystemBloc>(context);
    final enrichmentRequestBloc = BlocProvider.of<EnrichmentRequestBloc>(context);
    final enrichmentRequest = enrichmentRequestBloc.state.enrichmentRequest!;
    final payment = enrichmentRequest.payment;

    final currencySearchBloc = BlocProvider.of<CurrencySearchBloc>(context);
    final precisionMap = currencySearchBloc.state.precisionMap;
    final submittable = _tabController.index == 0 && _selectedPotentialMatchedDealIdx != null ||
        _tabController.index == 1 && _productController.text.isNotEmpty && _valueDateController.text.isNotEmpty;

    return SizedBox(
      width: 1100,
      child: Card(
        elevation: 12,
        child: Column(
          children: [
            // header,
            createHeader(
              enrichmentRequest.status,
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
                    // Payment Detail + Potential Match Detail / Auto Quote + Button Bar
                    Expanded(
                      flex: 8,
                      child: Column(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                createCaptionDivider(
                                  i18n.paymentPage.paymentDetail,
                                  defaultTextStyle(),
                                ),
                                createPaymentDetailTable(
                                  enrichmentRequest,
                                  i18n,
                                  precisionMap,
                                  defaultTextStyle(fontWeight: FontWeight.bold),
                                  defaultTextStyle(),
                                ),
                                createCaptionDivider(
                                  i18n.paymentPage.chooseYourAction,
                                  defaultTextStyle(),
                                ),
                                _createActionTabBar(i18n, themeData),
                                Expanded(
                                  child: _addPadding(
                                    TabBarView(
                                      controller: _tabController,
                                      children: [
                                        _createMatchingContainer(
                                            enrichmentRequestBloc.state.potentialMatchedDealList, i18n, themeData),
                                        _createBookingContainer(enrichmentRequestBloc.state.autoQuoteInfoList, i18n, themeData),
                                      ],
                                    ),
                                    bottom: 12.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _createButtonBar(
                            enrichmentRequest,
                            submittable,
                            i18n,
                            precisionMap,
                            () {
                              final productCode = _tabController.index == 0
                                  ? null
                                  : enrichmentRequestBloc.state.autoQuoteInfoList
                                      .firstWhere((element) => element.productName == _productController.text)
                                      .productCode;
                              final valueDate = _tabController.index == 0 ? null : dateFormat.parse(_valueDateController.text);
                              final fxd =
                                  _tabController.index == 0 ? potentialMatchedDeals[_selectedPotentialMatchedDealIdx!].fxd : null;

                              enrichmentRequestBloc.submitEnrichmentRequest(enrichmentRequest.id, fxd, productCode, valueDate);
                            },
                            () => enrichmentRequestBloc.editEnrichmentRequest(enrichmentRequest.id, payment,
                                fxRef: enrichmentRequest.fxRef),
                            () => enrichmentRequestBloc.cancelEnrichmentRequest(enrichmentRequest.id, payment),
                          )
                        ],
                      ),
                    ),
                    // Memo
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
                                bottom: 8.0,
                              ),
                              child: createMemoPane(
                                enrichmentRequest.memos,
                                i18n,
                                themeData,
                                defaultTextStyle(),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              bottom: 12.0,
                            ),
                            child: InputText(
                              controller: _memoController,
                              onChanged: (_) {
                                // Enable / Disable the Add button
                                setState(() {});
                              },
                              maxLines: 5,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Button(
                                text: i18n.add,
                                buttonType: ButtonType.secondary,
                                icon: const Icon(Icons.add),
                                enabled: _memoController.text.isNotEmpty,
                                onTap: () {
                                  systemBloc.showToast('Add Memo Success', ToastType.info);
                                  _memoController.text = '';
                                  setState(() {});
                                },
                              ),
                            ],
                          )
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

  Widget _createActionTabBar(Language i18n, ThemeData themeData) {
    final tickIcon = Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Icon(
        Icons.check_box,
        size: 16,
        color: themeData.primaryColor,
      ),
    );

    final selectedLabelTextStyle = defaultTextStyle(fontWeight: FontWeight.bold, color: themeData.textTheme.caption?.color);
    final unSelectedLabelTextStyle = defaultTextStyle(fontSize: BaseWidget.fontSize - 1, color: themeData.textTheme.caption?.color);

    return SizedBox(
      height: 30.0,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorPadding: EdgeInsets.zero,
          indicator: BoxDecoration(
            color: themeData.secondaryHeaderColor,
          ),
          tabs: <Widget>[
            Tab(
              icon: _tabController.index == 0
                  ? Row(
                      children: [
                        tickIcon,
                        Text(
                          i18n.paymentPage.matching,
                          style: selectedLabelTextStyle,
                        ),
                      ],
                    )
                  : Text(
                      i18n.paymentPage.matching,
                      style: unSelectedLabelTextStyle,
                    ),
            ),
            Tab(
              icon: _tabController.index == 1
                  ? Row(
                      children: [
                        tickIcon,
                        Text(
                          i18n.paymentPage.booking,
                          style: selectedLabelTextStyle,
                        ),
                      ],
                    )
                  : Text(
                      i18n.paymentPage.booking,
                      style: unSelectedLabelTextStyle,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createMatchingContainer(List<PotentialMatchedDeal> potentialMatchedDealList, Language i18n, ThemeData themeData) {
    final precisionMap = BlocProvider.of<CurrencySearchBloc>(context).state.precisionMap;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: themeData.dividerColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: DataGrid<PotentialMatchedDeal>(
          columns: [
            DataGridColumn(
              name: 'fxRef',
              label: i18n.paymentPage.fxRef,
              sortDirection: _columnSortDirection('fxRef'),
              width: 150,
            ),
            DataGridColumn(
              name: 'remainingCcy',
              label: i18n.paymentPage.remainingCcy,
              sortDirection: _columnSortDirection('remainingCcy'),
              width: 150,
            ),
            DataGridColumn(
              name: 'remainingAmount',
              label: i18n.paymentPage.remainingAmount,
              sortDirection: _columnSortDirection('remainingAmount'),
              width: 200,
            ),
            DataGridColumn(
              name: 'valueDate',
              label: i18n.paymentPage.valueDate,
              sortDirection: _columnSortDirection('valueDate'),
              width: 150,
            ),
            DataGridColumn(
              name: 'dealCcy',
              label: i18n.paymentPage.dealCcy,
              sortDirection: _columnSortDirection('dealCcy'),
              width: 150,
            ),
            DataGridColumn(
              name: 'dealAmount',
              label: i18n.paymentPage.dealAmount,
              sortDirection: _columnSortDirection('dealAmount'),
              width: 150,
            ),
            DataGridColumn(
              name: 'contraCcy',
              label: i18n.paymentPage.contraCcy,
              sortDirection: _columnSortDirection('contraCcy'),
              width: 150,
            ),
            DataGridColumn(
              name: 'contraAmount',
              label: i18n.paymentPage.contraAmount,
              sortDirection: _columnSortDirection('contraAmount'),
              width: 150,
            ),
          ],
          data: potentialMatchedDealList,
          valueFormatter: (deal, columnName) {
            final map = {
              'fxRef': deal.fxRef,
              'remainingCcy': deal.remainingCcy,
              'remainingAmount': formatNumber(deal.remainingAmount, precisionMap[deal.remainingCcy] ?? 2),
              'dealCcy': deal.dealCcy,
              'dealAmount': formatNumber(deal.dealAmount, precisionMap[deal.dealCcy] ?? 2),
              'contraCcy': deal.contraCcy,
              'contraAmount': formatNumber(deal.contraAmount, precisionMap[deal.contraCcy] ?? 2),
              'valueDate': dateFormat.format(deal.valueDate),
            };
            return map[columnName] ?? '';
          },
          showPagination: false,
          initialSelection: _selectedPotentialMatchedDealIdx != null ? [_selectedPotentialMatchedDealIdx!] : [],
          selectionType: SelectionType.single,
          selectionColor: themeData.secondaryHeaderColor,
          linkColor: themeData.primaryColor,
          hoverColor: themeData.backgroundColor,
          onSelectionChanged: (rows) {
            _selectedPotentialMatchedDealIdx = rows.isEmpty ? null : rows[0];
            setState(() {});
          },
          onSortChanged: (columnName, direction) {
            logger.d('Sorted changed, columnName = $columnName, direction = $direction');
            if (direction != null) {
              sortField = Pair(columnName, direction);
            } else {
              sortField = null;
            }
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _createBookingContainer(List<AutoQuoteInfo> autoQuoteInfoList, Language i18n, ThemeData themeData) {
    _productController.text = autoQuoteInfoList.first.productName;
    _valueDateController.text = dateFormat.format(autoQuoteInfoList.first.defaultValueDate!);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: themeData.dividerColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          children: [
            _addPadding(
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: InputDropdown(
                      label: i18n.paymentPage.product,
                      controller: _productController,
                      choices: {
                        for (var e in autoQuoteInfoList) e.productCode: e.productName,
                      },
                      mandatory: true,
                      reserveHelperTextSpace: true,
                      onChanged: (selectedProduct) => _valueDateController.text = dateFormat.format(autoQuoteInfoList
                          .firstWhere((element) => element.productName == selectedProduct.first)
                          .defaultValueDate!),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: filler,
                  ),
                  Expanded(
                    flex: 3,
                    child: InputDate(
                      label: i18n.paymentPage.valueDate,
                      controller: _valueDateController,
                      reserveHelperTextSpace: true,
                    ),
                  ),
                  const Expanded(
                    flex: 3,
                    child: filler,
                  ),
                ],
              ),
              top: 8.0,
              // bottom: 8.0,
            ),
            _addPadding(
              InputText(
                label: i18n.paymentPage.traderComment,
                controller: _traderCommentController,
                maxLines: 5,
              ),
              bottom: 8.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _createButtonBar(EnrichmentRequest enrichmentRequest, bool submittable, Language i18n, Map<String, int> precisionMap,
      VoidCallback submitAction, VoidCallback previousAction, VoidCallback cancelAction) {
    final payment = enrichmentRequest.payment;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _addPadding(
          Button(
            text: i18n.submit,
            buttonType: ButtonType.primary,
            icon: const Icon(Icons.check),
            enabled: submittable,
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => YesNoDialog(
                  title: _tabController.index == 0 ? i18n.paymentPage.matchPayment : i18n.paymentPage.newBooking,
                  subText: _tabController.index == 0
                      ? i18n.paymentPage.confirmMatching(potentialMatchedDeals[_selectedPotentialMatchedDealIdx!].fxRef)
                      : i18n.paymentPage.confirmBooking,
                  detail: _createDialogDetail(
                    i18n,
                    [
                      Pair(
                        i18n.paymentPage.instructionId,
                        '${payment.paymentRefType} ${payment.paymentRef!}',
                      ),
                      Pair(
                        i18n.paymentPage.account,
                        payment.accountRefs[0],
                      ),
                      Pair(
                        i18n.paymentPage.direction,
                        payment.direction == PaymentDirection.outgoing ? i18n.paymentPage.outgoing : i18n.paymentPage.incoming,
                      ),
                      Pair(
                        i18n.paymentPage.bankSell,
                        payment.creditAmount == null
                            ? payment.creditCcy
                            : '${payment.creditCcy} ${formatNumber(payment.creditAmount!, precisionMap[payment.creditCcy] ?? 2)}',
                      ),
                      Pair(
                        i18n.paymentPage.bankBuy,
                        payment.debitAmount == null
                            ? payment.debitCcy
                            : '${payment.debitCcy} ${formatNumber(payment.debitAmount!, precisionMap[payment.debitCcy] ?? 2)}',
                      ),
                      Pair(
                        i18n.paymentPage.executeDate,
                        dateFormat.format(payment.executeDate),
                      )
                    ],
                  ),
                  yesButtonProp: YesNoDialogButtonProp(
                    i18n.yes,
                    action: submitAction,
                  ),
                  noButtonProp: YesNoDialogButtonProp(
                    i18n.no,
                  ),
                ),
              );
            },
          ),
          right: 8.0,
        ),
        _addPadding(
          Button(
            text: i18n.previous,
            buttonType: ButtonType.secondary,
            icon: const Icon(Icons.arrow_back),
            onTap: previousAction,
          ),
          right: 8.0,
        ),
        Button(
          text: i18n.cancel,
          buttonType: ButtonType.secondary,
          icon: const Icon(Icons.cancel_outlined),
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => YesNoDialog(
                title: i18n.paymentPage.cancelPayment,
                subText: i18n.paymentPage.confirmCancelPayment,
                detail: _createDialogDetail(
                  i18n,
                  [
                    Pair(
                      i18n.paymentPage.instructionId,
                      '${payment.paymentRefType} ${payment.paymentRef!}',
                    ),
                    Pair(
                      i18n.paymentPage.account,
                      payment.accountRefs[0],
                    ),
                    Pair(
                      i18n.paymentPage.direction,
                      payment.direction == PaymentDirection.outgoing ? i18n.paymentPage.outgoing : i18n.paymentPage.incoming,
                    ),
                    Pair(
                      i18n.paymentPage.bankSell,
                      payment.creditAmount == null
                          ? payment.creditCcy
                          : '${payment.creditCcy} ${formatNumber(payment.creditAmount!, precisionMap[payment.creditCcy] ?? 2)}',
                    ),
                    Pair(
                      i18n.paymentPage.bankBuy,
                      payment.debitAmount == null
                          ? payment.debitCcy
                          : '${payment.debitCcy} ${formatNumber(payment.debitAmount!, precisionMap[payment.debitCcy] ?? 2)}',
                    ),
                    Pair(
                      i18n.paymentPage.executeDate,
                      dateFormat.format(payment.executeDate),
                    )
                  ],
                ),
                yesButtonProp: YesNoDialogButtonProp(
                  i18n.yes,
                  action: cancelAction,
                ),
                noButtonProp: YesNoDialogButtonProp(
                  i18n.no,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _createDialogDetail(Language i18n, List<Pair<String, String>> labelDescription) {
    return Column(
      children: labelDescription
          .map((e) => Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      e.left!,
                      style: defaultTextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: filler,
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      e.right!,
                      style: defaultTextStyle(),
                    ),
                  ),
                ],
              ))
          .toList(growable: false),
    );
  }

  SortDirection? _columnSortDirection(String columnName) {
    if (sortField != null) {
      if (columnName == sortField!.left) {
        return sortField!.right;
      } else {
        return null;
      }
    }
    return null;
  }

  Widget _addPadding(
    Widget widget, {
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: right, top: top, bottom: bottom),
      child: widget,
    );
  }
}
