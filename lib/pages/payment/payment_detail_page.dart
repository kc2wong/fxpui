import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'single_payment_page.dart';

import '../../bloc/currency_bloc.dart';
import '../../bloc/enrichment_request_bloc.dart';
import '../../localization/language.dart';
import '../../model/constant.dart';
import '../../model/payment.dart';
import '../../widget/base_widget.dart';

class PaymentDetailPage extends StatelessWidget with BaseWidget, SinglePaymentPage {
  static const filler = SizedBox.shrink();
  static const horizontalPadding = 20.0;

  final EnrichmentRequest enrichmentRequest;

  PaymentDetailPage(
    this.enrichmentRequest, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final themeData = Theme.of(context);
    final i18n = Language.of(context);

    final enrichmentRequestBloc = BlocProvider.of<EnrichmentRequestBloc>(context);
    final currencySearchBloc = context.read<CurrencySearchBloc>();
    final precisionMap = currencySearchBloc.state.precisionMap;

    final header = createHeader(
      enrichmentRequest.status,
      () => enrichmentRequestBloc.clearEnrichmentRequest(),
      i18n,
      horizontalPadding,
    );

    final detail = SizedBox(
      width: 1100,
      child: Card(
        elevation: 12,
        child: Column(
          children: [
            header,
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  bottom: 16.0,
                ),
                child: Row(
                  children: [
                    // Payment Detail and Matching Result
                    Expanded(
                      flex: 8,
                      child: Column(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                  i18n.paymentPage.enrichmentResult,
                                  defaultTextStyle(),
                                ),
                                createEnrichmentResultTable(
                                  enrichmentRequest,
                                  i18n,
                                  precisionMap,
                                  defaultTextStyle(fontWeight: FontWeight.bold),
                                  defaultTextStyle(),
                                ),
                                enrichmentRequest.failureMessages.isNotEmpty
                                    ? Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: enrichmentRequest.failureMessages
                                        .map(
                                          (e) => Text(
                                        e,
                                        style: defaultTextStyle(color: Colors.red),
                                      ),
                                    )
                                        .toList(growable: false),
                                  ),
                                )
                                    : BaseWidget.filler,
                              ],
                            ),
                          ),
                          // buttonBar,
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

    return Center(
      child: Column(
        children: [
          const Expanded(
            child: filler,
            flex: 1,
          ),
          Expanded(
            child: detail,
            flex: 9,
          ),
          const Expanded(
            child: filler,
            flex: 2,
          ),
        ],
      ),
    );
  }

  TableRow? _createTableRow(List<Widget> widgets) {
    if (widgets.where((element) => element != BaseWidget.filler).isNotEmpty) {
      final children = widgets
          .map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: e,
      ))
          .toList(growable: false);
      return TableRow(
        children: children,
      );
    } else {
      return null;
    }
  }

  Widget createEnrichmentResultTable(EnrichmentRequest enrichmentRequest, Language i18n, Map<String, int> precisionMap,
      TextStyle captionTextStyle, TextStyle textStyle) {
    final enrichmentResultDetail = [
      _createTableRow(
        [
          enrichmentRequest.fxd != null
              ? Text(
            i18n.paymentPage.fxd,
            style: captionTextStyle,
          )
              : BaseWidget.filler,
          enrichmentRequest.fxd != null
              ? Text(
            enrichmentRequest.fxd!,
            style: textStyle,
          )
              : BaseWidget.filler,
          enrichmentRequest.fxt != null
              ? Text(
            i18n.paymentPage.fxt,
            style: captionTextStyle,
          )
              : BaseWidget.filler,
          enrichmentRequest.fxt != null
              ? Text(
            enrichmentRequest.fxt!,
            style: textStyle,
          )
              : BaseWidget.filler,
        ],
      ),
      _createTableRow(
        [
          enrichmentRequest.product != null
              ? Text(
            i18n.paymentPage.product,
            style: captionTextStyle,
          )
              : BaseWidget.filler,
          enrichmentRequest.ccyPair != null
              ? Text(
            enrichmentRequest.product!,
            style: textStyle,
          )
              : BaseWidget.filler,
          enrichmentRequest.valueDate != null
              ? Text(
            i18n.paymentPage.valueDate,
            style: captionTextStyle,
          )
              : BaseWidget.filler,
          enrichmentRequest.valueDate != null
              ? Text(
            dateFormat.format(enrichmentRequest.valueDate!),
            style: textStyle,
          )
              : BaseWidget.filler,
        ],
      ),
      _createTableRow(
        [
          enrichmentRequest.ccyPair != null
              ? Text(
            i18n.paymentPage.ccyPair,
            style: captionTextStyle,
          )
              : BaseWidget.filler,
          enrichmentRequest.ccyPair != null
              ? Text(
            enrichmentRequest.ccyPair!,
            style: textStyle,
          )
              : BaseWidget.filler,
          enrichmentRequest.rate != null
              ? Text(
            i18n.paymentPage.rate,
            style: captionTextStyle,
          )
              : BaseWidget.filler,
          enrichmentRequest.rate != null
              ? Text(
            enrichmentRequest.rate!.toString(),
            style: textStyle,
          )
              : BaseWidget.filler,
        ],
      ),
    ].where((element) => element != null).map((e) => e!).toList(growable: false);

    return enrichmentResultDetail.isNotEmpty
        ? Table(
      columnWidths: const <int, TableColumnWidth>{
        0: FractionColumnWidth(0.2),
        1: FractionColumnWidth(0.3),
        2: FractionColumnWidth(0.2),
        3: FractionColumnWidth(0.3),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: enrichmentResultDetail,
    )
        : BaseWidget.filler;
  }
}

