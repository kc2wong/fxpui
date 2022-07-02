import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/account_bloc.dart';
import '../../localization/language.dart';
import '../../model/client.dart';
import '../../theme/app_theme.dart';
import '../../widget/base_widget.dart';
import '../../widget/data_grid.dart';

class AccountDetailPage extends StatelessWidget with BaseWidget {
  static const filler = SizedBox.shrink();
  static const formWidth = 800.0;
  static const padding = 16.0;

 final FxAccount fxAccount;

  AccountDetailPage(
    this.fxAccount, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final themeData = Theme.of(context);
    final i18n = Language.of(context);
    final fxAccountSearchBloc = BlocProvider.of<FxAccountSearchBloc>(context);

    final header = Container(
      color: themeData.selectedRowColor,
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: padding),
            child: Text(
              i18n.paymentPage.accountDetail,
              style: TextStyle(
                color: AppTheme.light.textTheme.bodyText1?.color,
              ),
            ),
          ),
          IconButton(
            onPressed: () => fxAccountSearchBloc.unSelectFxAccount(),
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

    final accountDetail = Padding(
      padding: const EdgeInsets.all(
        padding,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
            ),
            child: createAccountDetailTable(
              fxAccount,
              i18n,
              defaultTextStyle(fontWeight: FontWeight.bold),
              defaultTextStyle(),
            ),
          ),
          createCaptionDivider(
            'External Accounts',
            defaultTextStyle(),
          ),
          Expanded(
            child: createExternalAccountDetailTable(
              fxAccount.externalAccount,
              i18n,
              themeData,
            ),
          ),
        ],
      ),
    );

    final content = SizedBox(
      width: formWidth,
      child: Card(
        elevation: 12,
        child: Column(
          children: [
            header,
            Expanded(
              child: accountDetail,
            )
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
            child: content,
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

  Widget createAccountDetailTable(FxAccount fxAccount, Language i18n, TextStyle captionTextStyle, TextStyle textStyle) {

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
              i18n.accountPage.fxAccount,
              style: captionTextStyle,
            ),
            Text(
              fxAccount.clientId,
              style: textStyle,
            ),
            Text(
              i18n.accountPage.name,
              style: captionTextStyle,
            ),
            Text(
              fxAccount.name,
              style: textStyle,
            ),
          ],
        ),
        _createTableRow(
          [
            Text(
              i18n.accountPage.status,
              style: captionTextStyle,
            ),
            Text(
              'ACTIVE',
              style: textStyle,
            ),
            BaseWidget.filler,
            BaseWidget.filler,
          ],
        ),
      ].map((e) => e!).toList(growable: false),
    );
  }

  Widget createExternalAccountDetailTable(List<ExternalAccountRef> externalAccounts, Language i18n, ThemeData themeData) {

    const availableWidth = formWidth - padding * 2;

    return DataGrid<ExternalAccountRef>(
      columns: [
        DataGridColumn(
          name: 'refType',
          label: i18n.accountPage.type,
          width: availableWidth / 4,
        ),
        DataGridColumn(
          name: 'ref',
          label: i18n.accountPage.ref,
          width: availableWidth / 4,
        ),
        DataGridColumn(
          name: 'name',
          label: i18n.accountPage.name,
          width: availableWidth / 2 - padding,
        ),
      ],
      data: externalAccounts,
      valueFormatter: (externalAccount, columnName) {
        final map = {
          'refType': externalAccount.refType,
          'ref': externalAccount.ref,
          'name': externalAccount.name ?? '',
        };
        return map[columnName] ?? '';
      },
      showPagination: false,
      selectionType: SelectionType.none,
      hoverColor: themeData.backgroundColor,
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

