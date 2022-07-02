import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../bloc/site_bloc.dart';
import '../../bloc/currency_bloc.dart';
import '../../bloc/enrichment_request_bloc.dart';
import '../../bloc/system_bloc.dart';
import '../../bloc/enrichment_request_search_bloc.dart';
import '../../bloc/state/site_state.dart';
import '../../bloc/state/enrichment_request_search_state.dart';
import '../../localization/language.dart';
import '../../model/constant.dart';
import '../../model/currency.dart';
import '../../model/payment.dart';
import '../../model/system.dart';
import '../../theme/app_theme.dart';
import '../../util/logger.dart';
import '../../widget/base_widget.dart';
import '../../widget/button.dart';
import '../../widget/data_grid.dart';
import '../../widget/input_date.dart';
import '../../widget/input_dropdown.dart';
import '../../widget/input_group.dart';
import '../../widget/input_number.dart';
import '../../widget/input_text.dart';

import 'utils.dart';

class PaymentListingPage extends StatefulWidget {
  const PaymentListingPage({Key? key}) : super(key: key);

  @override
  State<PaymentListingPage> createState() => _PaymentListingPageState();
}

class _PaymentListingPageState extends State<PaymentListingPage> with BaseWidget {
  Pair<String, SortDirection>? sortField;

  late bool _showSearchCriteria;
  late bool _animationDone;

  late TextEditingController _requestStatusController;
  late TextEditingController _instructionIdController;
  late TextEditingController _accountController;
  late TextEditingController _execDateFromController;
  late TextEditingController _execDateToController;
  late TextEditingController _initiatedByController;
  late TextEditingController _debitCcyController;
  late TextEditingController _debitAmountFromController;
  late TextEditingController _debitAmountToController;
  late TextEditingController _creditCcyController;
  late TextEditingController _creditAmountFromController;
  late TextEditingController _creditAmountToController;

  @override
  void initState() {
    super.initState();

    logger.d('_PaymentListingPageState.initState() triggered');

    _requestStatusController = TextEditingController();
    _instructionIdController = TextEditingController();
    _accountController = TextEditingController();
    _execDateFromController = TextEditingController();
    _execDateToController = TextEditingController();
    _initiatedByController = TextEditingController();
    _debitCcyController = TextEditingController();
    _debitAmountFromController = TextEditingController();
    _debitAmountToController = TextEditingController();
    _creditCcyController = TextEditingController();
    _creditAmountFromController = TextEditingController();
    _creditAmountToController = TextEditingController();

    _showSearchCriteria = true;
    _animationDone = true;

    final EnrichmentRequestSearchBloc enrichmentRequestSearchBloc = BlocProvider.of<EnrichmentRequestSearchBloc>(context);

    if (!enrichmentRequestSearchBloc.state.dataFetched()) {
      enrichmentRequestSearchBloc.resetState(siteCode: context.read<SiteSearchBloc>().state.selectedSite?.siteCode);
    }
  }

  @override
  void dispose() {
    _accountController.dispose();
    _instructionIdController.dispose();
    _requestStatusController.dispose();
    _execDateFromController.dispose();
    _initiatedByController.dispose();
    _debitCcyController.dispose();
    _debitAmountFromController.dispose();
    _debitAmountToController.dispose();
    _creditCcyController.dispose();
    _creditAmountFromController.dispose();
    _creditAmountToController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final i18n = Language.of(context);
    final EnrichmentRequestSearchBloc paymentSearchBloc = BlocProvider.of<EnrichmentRequestSearchBloc>(context);

    final systemBloc = BlocProvider.of<SystemBloc>(context);
    final EnrichmentRequestSearchBloc enrichmentRequestSearchBloc = BlocProvider.of<EnrichmentRequestSearchBloc>(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<EnrichmentRequestSearchBloc, EnrichmentRequestSearchState>(
          // trigger a search if there is no data.  Show / hide loading indicator when search starts / finishes
          listenWhen: (previous, current) {
            return !current.dataFetched() || previous.loading != current.loading || current.lastActionTime > previous.lastActionTime;
          },
          listener: (_, state) {
            if (state.loading) {
              systemBloc.startLoading();
            }
            else {
              if (state.dataFetched()) {
                systemBloc.stopLoading();
                if (state.errorCode != null) {
                  systemBloc.showToast(
                    i18n.getErrorMessage(state.errorCode!, state.errorParams ?? []),
                    ToastType.error,
                  );
                }
                else if (state.refreshSuccessMessage != null) {
                  systemBloc.showToast(
                    state.refreshSuccessMessage!,
                    ToastType.success,
                  );
                }
              }
              else if (state.siteCode != null){
                enrichmentRequestSearchBloc.refreshData(forceRefresh: false);
              }
            }
          },
        ),
        BlocListener<SiteSearchBloc, SiteSearchState>(
          // When selected site is changed, search data again
          listenWhen: (previous, current) => previous.selectedSite?.siteCode != current.selectedSite?.siteCode,
          listener: (_, state) {
            enrichmentRequestSearchBloc.resetState(siteCode: state.selectedSite?.siteCode);
          },
        ),
      ],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _searchCriteriaPanel(themeData, i18n, paymentSearchBloc),
          const VerticalDivider(
            width: 1,
            thickness: 1,
            indent: 0,
            endIndent: 0,
          ),
          Expanded(
            child: _searchResultPanel(i18n),
          ),
        ],
      ),
    );
  }

  Widget _searchCriteriaPanel(ThemeData themeData, Language i18n, EnrichmentRequestSearchBloc paymentSearchBloc) {
    bool isOpen = false;
    if (!_showSearchCriteria) {
      isOpen = _animationDone;
    } else {
      isOpen = !_animationDone;
    }

    final currencySearchBloc = context.read<CurrencySearchBloc>();
    final precisionMap = currencySearchBloc.state.precisionMap;
    final ccyList = (currencySearchBloc.state.currencyList ?? <Currency>[]).map((e) => e.isoCcy).toList(growable: false);
    final ccyMap = {for (var e in ccyList) e: e};

    final hideIconWithHint = _addBottomRightPadding(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            i18n.searchCriteria,
            style: defaultTextStyle(),
          ),
          _hideShowButton(i18n, isOpen),
        ],
      ),
      bottomPadding: 9,
      rightPadding: 0,
    );

    final searchPanel = _animationDone && _showSearchCriteria
        ? Scrollbar(
            // isAlwaysShown: true,
            thumbVisibility: true,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(right: 10),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                ),
                child: BlocBuilder<EnrichmentRequestSearchBloc, EnrichmentRequestSearchState>(
                  builder: (_, state) {
                    return Column(
                      children: [
                        hideIconWithHint,
                        ...[
                          _requestStatusCriteria(i18n, state),
                          _instructionIdCriteria(i18n, state),
                          _accountCriteria(i18n, state),
                          _executeDateCriteria(i18n, state),
                          _initiatedByCriteria(i18n, state),
                          _creditAmountCriteria(i18n, state, ccyMap, precisionMap),
                        ].map((e) => _addBottomRightPadding(e)).toList(growable: false),
                        _addBottomRightPadding(
                          _debitAmountCriteria(i18n, state, ccyMap, precisionMap),
                          bottomPadding: 24,
                        ),
                        _addBottomRightPadding(
                          _searchResetButton(i18n, state),
                          bottomPadding: 48,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          )
        : Container(
            alignment: Alignment.topRight,
            padding: isOpen ? EdgeInsets.zero : const EdgeInsets.only(right: 10),
            child: _hideShowButton(i18n, isOpen),
          );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.linear,
      width: _showSearchCriteria ? 400 : 50,
      child: searchPanel,
      onEnd: () {
        _animationDone = true;
        // Repaint the search panel again
        setState(() {});
      },
    );
  }

  Widget _searchResultPanel(Language i18n) {
    final themeData = Theme.of(context);

    final systemBloc = BlocProvider.of<SystemBloc>(context);
    final enrichmentRequestBloc = BlocProvider.of<EnrichmentRequestBloc>(context);
    final precisionMap = BlocProvider.of<CurrencySearchBloc>(context).state.precisionMap;

    return BlocBuilder<EnrichmentRequestSearchBloc, EnrichmentRequestSearchState>(
      builder: (_, state) {
        return Padding(
          padding: const EdgeInsets.all(BaseWidget.inputBoxPadding),
          child: DataGrid<EnrichmentRequest>(
            columns: [
              DataGridColumn(
                  name: 'requestStatus',
                  label: i18n.paymentPage.requestStatus,
                  sortDirection: _columnSortDirection('requestStatus'),
                  width: 150),
              DataGridColumn(
                  name: 'instructionId',
                  label: i18n.paymentPage.instructionId,
                  sortDirection: _columnSortDirection('instructionId'),
                  width: 200),
              DataGridColumn(
                  name: 'account', label: i18n.paymentPage.account, sortDirection: _columnSortDirection('account'), width: 150),
              DataGridColumn(
                  name: 'executeDate',
                  label: i18n.paymentPage.executeDate,
                  sortDirection: _columnSortDirection('executeDate'),
                  width: 150),
              DataGridColumn(
                  name: 'initiatedBy',
                  label: i18n.paymentPage.initiatedBy,
                  sortDirection: _columnSortDirection('initiatedBy'),
                  width: 150),
              DataGridColumn(name: 'creditCcy', label: 'Credit CCY', sortDirection: _columnSortDirection('creditCcy'), width: 150),
              DataGridColumn(
                  name: 'creditAmount', label: 'Credit Amount', sortDirection: _columnSortDirection('creditAmount'), width: 150),
              DataGridColumn(name: 'debitCcy', label: 'Debit CCY', sortDirection: _columnSortDirection('debitCcy'), width: 150),
              DataGridColumn(
                  name: 'debitAmount', label: 'Debit Amount', sortDirection: _columnSortDirection('debitAmount'), width: 150),
              DataGridColumn(name: 'ccyPair', label: 'CCY Pair', sortDirection: _columnSortDirection('ccyPair'), width: 150),
              DataGridColumn(name: 'rate', label: 'Rate', sortDirection: _columnSortDirection('rate'), width: 100),
              DataGridColumn(name: 'product', label: 'Product', sortDirection: _columnSortDirection('requestStatus'), width: 250),
            ],
            data: state.searchResult?.elements ?? [],
            valueFormatter: (enrichmentRequest, columnName) {
              final payment = enrichmentRequest.payment;
              final map = {
                'requestStatus': i18n.paymentPage.getEnrichmentStatusDescription(enrichmentRequest.status),
                'instructionId': payment.paymentRef,
                'account': payment.accountRefs.isNotEmpty ? payment.accountRefs[0] : '',
                'executeDate': dateFormat.format(payment.executeDate),
                'initiatedBy': enrichmentRequest.initiatedBy,
                'creditCcy': enrichmentRequest.payment.creditCcy,
                'creditAmount': payment.creditAmount != null
                    ? formatNumber(payment.creditAmount!, precisionMap[enrichmentRequest.payment.creditCcy] ?? 2)
                    : '',
                'debitCcy': payment.debitCcy,
                'debitAmount': payment.debitAmount != null
                    ? formatNumber(payment.debitAmount!, precisionMap[enrichmentRequest.payment.debitCcy] ?? 2)
                    : '',
                'ccyPair': enrichmentRequest.ccyPair,
                'rate': enrichmentRequest.rate != null ? formatNumber(enrichmentRequest.rate!, 2) : '',
                'product': enrichmentRequest.product,
              };
              return map[columnName] ?? '';
            },
            valueStyleProvider: (value, columnName) {
              if (columnName == 'requestStatus') {
                final requestStatus = EnrichmentRequestStatus.values
                    .firstWhere((element) => i18n.paymentPage.getEnrichmentStatusDescription(element) == value);
                return TextStyle(
                  color: AppTheme.light.textTheme.bodyText1?.color,
                  backgroundColor: getEnrichmentRequestStatusColor(requestStatus),
                );
              }
              return null;
            },
            actionProvider: (item, columnName) {
              if (columnName == 'instructionId') {
                return () {
                  enrichmentRequestBloc.getEnrichmentRequest(item.id);
                };
              } else {
                return null;
              }
            },
            selectionColor: themeData.secondaryHeaderColor,
            linkColor: themeData.primaryColor,
            hoverColor: themeData.backgroundColor,
            onSortChanged: (columnName, direction) {
              systemBloc.showToast('Sorted changed, columnName = $columnName, direction = $direction', ToastType.info,
                  autoDismissMillis: 1000);
              if (direction != null) {
                sortField = Pair(columnName, direction);
              } else {
                sortField = null;
              }
              setState(() {});
            },
            lastRefreshTime: state.lastSuccessRefreshTime,
          ),
        );
      },
    );
  }

  Widget _hideShowButton(Language i18n, bool isOpen) {
    return Button(
      buttonType: ButtonType.iconOnly,
      text: isOpen ? i18n.expandSearchPanel : i18n.collapseSearchPanel,
      icon: Icon(
        isOpen ? MdiIcons.chevronDoubleRight : MdiIcons.chevronDoubleLeft,
        size: BaseWidget.iconSize + 8,
      ),
      onTap: () {
        _showSearchCriteria = !_showSearchCriteria;
        _animationDone = false;
        setState(() {});
      },
    );
  }

  Widget _requestStatusCriteria(Language i18n, EnrichmentRequestSearchState state) {
    final requestStatusMap = {for (var e in EnrichmentRequestStatus.values) e: i18n.paymentPage.getEnrichmentStatusDescription(e)};

    return InputDropdown<EnrichmentRequestStatus>(
      label: i18n.paymentPage.requestStatus,
      initialValue: state.enrichmentRequestStatus,
      multipleSelection: true,
      controller: _requestStatusController,
      showSearchBox: true,
      choices: requestStatusMap,
    );
  }

  Widget _instructionIdCriteria(Language i18n, EnrichmentRequestSearchState state) {
    return InputText(
      label: i18n.paymentPage.instructionId,
      initialValue: state.instructionId,
      controller: _instructionIdController,
    );
  }

  Widget _accountCriteria(Language i18n, EnrichmentRequestSearchState state) {
    return InputText(
      label: i18n.paymentPage.account,
      initialValue: state.account,
      controller: _accountController,
    );
  }

  Widget _executeDateCriteria(Language i18n, EnrichmentRequestSearchState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              right: 5,
            ),
            child: InputDate(
              label: i18n.paymentPage.executeDateFromTo,
              dateFormat: dateFormatStr,
              hint: dateFormatStr,
              initialValue: state.executionDateFrom,
              controller: _execDateFromController,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 5,
            ),
            child: InputDate(
              dateFormat: dateFormatStr,
              hint: dateFormatStr,
              initialValue: state.executionDateTo,
              controller: _execDateToController,
            ),
          ),
        ),
      ],
    );
  }

  Widget _initiatedByCriteria(Language i18n, EnrichmentRequestSearchState state) {
    return InputText(
      label: i18n.paymentPage.initiatedBy,
      initialValue: state.initiatedBy,
      controller: _initiatedByController,
    );
  }

  Widget _creditAmountCriteria(
      Language i18n, EnrichmentRequestSearchState state, Map<String, String> ccyMap, Map<String, int> precisionMap) {
    return InputGroup(
      label: i18n.paymentPage.bankSell,
      widgets: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: InputDropdown<String>(
                  hint: i18n.ccy,
                  initialValue: state.creditCcy != null ? [state.creditCcy!] : null,
                  controller: _creditCcyController,
                  showSearchBox: true,
                  choices: ccyMap,
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: InputNumber(
                  hint: i18n.fromAmount,
                  initialValue: state.creditAmountFrom,
                  controller: _creditAmountFromController,
                  numberOfDecimal: _creditCcyController.text.isNotEmpty ? precisionMap[_creditCcyController.text] ?? 2 : 2,
                ),
              ),
              flex: 1,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: InputNumber(
                  hint: i18n.toAmount,
                  initialValue: state.creditAmountTo,
                  controller: _creditAmountToController,
                  numberOfDecimal: _creditCcyController.text.isNotEmpty ? precisionMap[_creditCcyController.text] ?? 2 : 2,
                ),
              ),
              flex: 1,
            ),
          ],
        )
      ],
    );
  }

  Widget _debitAmountCriteria(
      Language i18n, EnrichmentRequestSearchState state, Map<String, String> ccyMap, Map<String, int> precisionMap) {
    return InputGroup(
      label: i18n.paymentPage.bankBuy,
      widgets: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: InputDropdown<String>(
                  hint: i18n.ccy,
                  initialValue: state.debitCcy != null ? [state.debitCcy!] : null,
                  controller: _debitCcyController,
                  choices: ccyMap,
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: InputNumber(
                  hint: i18n.fromAmount,
                  initialValue: state.debitAmountFrom,
                  controller: _debitAmountFromController,
                  numberOfDecimal: _debitCcyController.text.isNotEmpty ? precisionMap[_debitCcyController.text] ?? 2 : 2,
                ),
              ),
              flex: 1,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: InputNumber(
                  hint: i18n.toAmount,
                  initialValue: state.debitAmountTo,
                  controller: _debitAmountToController,
                  numberOfDecimal: _debitCcyController.text.isNotEmpty ? precisionMap[_debitCcyController.text] ?? 2 : 2,
                ),
              ),
              flex: 1,
            ),
          ],
        )
      ],
    );
  }

  Widget _searchResetButton(Language i18n, EnrichmentRequestSearchState state) {
    final siteCode = context.read<SiteSearchBloc>().state.selectedSite!.siteCode;
    final enrichmentRequestSearchBloc = BlocProvider.of<EnrichmentRequestSearchBloc>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Button(
            buttonType: ButtonType.secondary,
            onTap: () => enrichmentRequestSearchBloc.resetState(siteCode: siteCode),
            text: i18n.reset,
          ),
        ),
        Button(
          buttonType: ButtonType.primary,
          onTap: () {
            _search(i18n, siteCode, enrichmentRequestSearchBloc);
          },
          text: i18n.submit,
        )
      ],
    );
  }

  Widget _addBottomRightPadding(
    Widget widget, {
    double bottomPadding = 18,
    double rightPadding = 12,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding, right: rightPadding),
      child: widget,
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

  void _search(Language i18n, String siteCode, EnrichmentRequestSearchBloc enrichmentRequestSearchBloc) {
    final requestStatus = _requestStatusController.text.isEmpty
        ? <EnrichmentRequestStatus>[]
        : _requestStatusController.text
            .split(',')
            .map((e) => i18n.paymentPage.getEnrichmentStatus(e.trim()))
            .where((e) => e != null)
            .map((e) => e!)
            .toList(growable: false);
    final executeDateFrom = _execDateFromController.text.isEmpty ? null : dateFormat.parse(_execDateFromController.text);
    final executeDateTo = _execDateToController.text.isEmpty ? null : dateFormat.parse(_execDateToController.text);
    final creditAmountFrom =
        _creditAmountFromController.text.isEmpty ? null : double.tryParse(_creditAmountFromController.text.replaceAll(',', ''));
    final creditAmountTo =
        _creditAmountToController.text.isEmpty ? null : double.tryParse(_creditAmountToController.text.replaceAll(',', ''));
    final debitAmountFrom =
        _debitAmountFromController.text.isEmpty ? null : double.tryParse(_debitAmountFromController.text.replaceAll(',', ''));
    final debitAmountTo =
        _debitAmountToController.text.isEmpty ? null : double.tryParse(_debitAmountToController.text.replaceAll(',', ''));

    enrichmentRequestSearchBloc.search(
      siteCode: siteCode,
      offSet: 0,
      pageSize: pageSize,
      enrichmentRequestStatus: requestStatus,
      instructionId: _instructionIdController.text.isEmpty ? null : _instructionIdController.text,
      account: _accountController.text.isEmpty ? null : _accountController.text,
      executionDateFrom: executeDateFrom,
      executionDateTo: executeDateTo,
      creditCcy: _creditCcyController.text.isEmpty ? null : _creditCcyController.text,
      creditAmountFrom: creditAmountFrom,
      creditAmountTo: creditAmountTo,
      debitCcy: _debitCcyController.text.isEmpty ? null : _debitCcyController.text,
      debitAmountFrom: debitAmountFrom,
      debitAmountTo: debitAmountTo,
    );
  }
}
