import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widget/base_widget.dart';
import '../../localization/language.dart';
import '../../model/payment.dart';
import '../../model/constant.dart';
import 'utils.dart';

class SinglePaymentPage {
  Widget createCaptionDivider(String caption, TextStyle textStyle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Expanded(
            child: Divider(
              thickness: 2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              caption,
              style: textStyle,
            ),
          ),
          const Expanded(
            child: Divider(
              thickness: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget createHeader(EnrichmentRequestStatus status, VoidCallback closeButtonAction, Language i18n, double horizontalPadding) {

    return Container(
      color: getEnrichmentRequestStatusColor(
        status,
      ),
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: horizontalPadding),
            child: Text(
              '${i18n.paymentPage.requestStatus} : ${i18n.paymentPage.getEnrichmentStatusDescription(status)}',
              style: TextStyle(
                // For dark theme, the text color is white, which is difficult to view, therefore use the dark color of light theme
                color: AppTheme.light.textTheme.bodyText1?.color,
              ),
            ),
          ),
          IconButton(
            onPressed: closeButtonAction,
            icon: Icon(
              Icons.close,
              size: 16,
              color: AppTheme.light.textTheme.bodyText1?.color,
            ),
            splashRadius: 1.0,
          ),
        ],
      ),
    );
  }

  Widget createPaymentDetailTable(EnrichmentRequest enrichmentRequest, Language i18n, Map<String, int> precisionMap, TextStyle captionTextStyle, TextStyle textStyle) {
    final payment = enrichmentRequest.payment;

    return Table(
      columnWidths: const <int, TableColumnWidth>{
        0: FractionColumnWidth(0.2),
        1: FractionColumnWidth(0.3),
        2: FractionColumnWidth(0.2),
        3: FractionColumnWidth(0.3),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        _createTableRow(
          [
            Text(
              i18n.paymentPage.account1,
              style: captionTextStyle,
            ),
            Text(
              payment.accountRefs[0],
              style: textStyle,
            ),
            numberOfInputAccount == 2
                ? Text(
              i18n.paymentPage.account2,
              style: captionTextStyle,
            )
                : BaseWidget.filler,
            numberOfInputAccount == 2
                ? Text(
              payment.accountRefs[1],
              style: textStyle,
            )
                : BaseWidget.filler,
          ],
        ),
        _createTableRow(
          [
            Text(
              i18n.paymentPage.direction,
              style: captionTextStyle,
            ),
            Text(
              payment.direction == PaymentDirection.outgoing ? i18n.paymentPage.outgoing : i18n.paymentPage.incoming,
              style: textStyle,
            ),
            BaseWidget.filler,
            BaseWidget.filler,
          ],
        ),
        _createTableRow(
          [
            Text(
              i18n.paymentPage.bankSell,
              style: captionTextStyle,
            ),
            Text(
              payment.creditAmount != null
                  ? '${payment.creditCcy} ${formatNumber(payment.creditAmount!, precisionMap[payment.creditCcy] ?? 2)}'
                  : payment.creditCcy,
              style: textStyle,
            ),
            Text(
              i18n.paymentPage.bankBuy,
              style: captionTextStyle,
            ),
            Text(
              payment.debitAmount != null
                  ? '${payment.debitCcy} ${formatNumber(payment.debitAmount!, precisionMap[payment.debitCcy] ?? 2)}'
                  : payment.debitCcy,
              style: textStyle,
            ),
          ],
        ),
        _createTableRow(
          [
            Text(
              i18n.paymentPage.instructionId,
              style: captionTextStyle,
            ),
            payment.paymentRef != null
                ? Text(
                    '${payment.paymentRefType!} ${payment.paymentRef!}',
                    style: textStyle,
                  )
                : BaseWidget.filler,
            Text(
              i18n.paymentPage.executeDate,
              style: captionTextStyle,
            ),
            Text(
              dateFormat.format(payment.executeDate),
              style: textStyle,
            ),
          ],
        ),
        _createTableRow(
          [
            Text(
              i18n.paymentPage.fxRef,
              style: captionTextStyle,
            ),
            enrichmentRequest.fxRef != null
                ? Text(
              enrichmentRequest.fxRef!,
              style: captionTextStyle,
            )
                : BaseWidget.filler,
            BaseWidget.filler,
            BaseWidget.filler,
          ],
        ),
      ].map((e) => e!).toList(growable: false),
    );
  }

  Widget createMemoPane(List<Memo> memos, Language i18n, ThemeData themeData, TextStyle textStyle) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: themeData.dividerColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: memos.isEmpty
          ? null
          : Column(
              children: memos
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: 4.0,
                      ),
                      child: ListTile(
                        title: Text(
                          dateTimeFormat.format(e.createdTime),
                          style: textStyle,
                        ),
                        subtitle: Text(
                          e.content,
                          style: textStyle,
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
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

}