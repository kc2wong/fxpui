import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../localization/language.dart';
import '../widget/base_widget.dart';

import '../util/logger.dart';

typedef ValueFormatter<T> = String Function(T item, String columnName);
typedef ValueStyleProvider = TextStyle? Function(String? value, String columnName);
typedef ActionProvider<T> = VoidCallback? Function(T item, String columnName);
typedef SortChanged = void Function(String columnName, SortDirection? sortDirection);
typedef SelectionChanged = void Function(List<int> selectedRows);

enum SortDirection {
  ascending,
  descending,
}

enum SelectionType {
  none,
  single,
  multiple
}

class DataGridColumn {
  final String name;
  final String label;
  final double width;
  final bool sortable;
  final SortDirection? sortDirection;

  DataGridColumn({
    required this.name,
    required this.label,
    required this.width,
    this.sortable = true,
    this.sortDirection,
  });
}

class DataGrid<T> extends StatefulWidget {
  static const rowHeight = 40.0;

  final List<DataGridColumn> columns;
  final List<T> data;
  final ValueFormatter<T> valueFormatter;
  final ValueStyleProvider? valueStyleProvider;
  final ActionProvider<T>? actionProvider;
  final SortChanged? onSortChanged;
  final bool showPagination;
  final DateTime? lastRefreshTime;
  final SelectionType selectionType;
  final SelectionChanged? onSelectionChanged;
  final List<int>? initialSelection;

  final Color? selectionColor;
  final Color? linkColor;
  final Color? hoverColor;

  // Yes to fit column width by container width
  final bool autoFit;
  late final double _totalWidth;

  DataGrid({
    Key? key,
    required this.columns,
    required this.data,
    required this.valueFormatter,
    this.valueStyleProvider,
    this.actionProvider,
    this.onSortChanged,
    this.autoFit = false,
    this.showPagination = true,
    this.lastRefreshTime,
    this.selectionType = SelectionType.none,
    this.onSelectionChanged,
    this.initialSelection,
    this.selectionColor,
    this.linkColor,
    this.hoverColor,
  }) : super(key: key) {
    _totalWidth = columns.map((e) => e.width).reduce((value, element) => value + element);
    logger.d('totalWidth = $_totalWidth');
  }

  @override
  State<DataGrid<T>> createState() => _DataGridState<T>();
}

class _DataGridState<T> extends State<DataGrid<T>> with BaseWidget {
  // late List<int> selectedIndexes;
  late final DataGridController _dataGridController;
  late final DataGridSource _dataSource;

  @override
  void initState() {
    super.initState();
    _dataGridController = DataGridController();

    _dataSource = DataGridSourceImpl(
      widget.data,
      widget.columns,
      widget.valueFormatter,
      widget.valueStyleProvider,
      widget.actionProvider,
      widget.linkColor,
      widget.hoverColor,
      widget.initialSelection,
    );

  }


  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final i18n = Language.of(context);

    final selectionMode = widget.selectionType == SelectionType.none
        ? SelectionMode.none
        : widget.selectionType == SelectionType.single
            ? SelectionMode.singleDeselect
            : SelectionMode.multiple;

    // If required to select initial rows, need to use single datasource in stead of creating new one on the fly
    final dataSource = widget.initialSelection != null ? _dataSource : DataGridSourceImpl(
      widget.data,
      widget.columns,
      widget.valueFormatter,
      widget.valueStyleProvider,
      widget.actionProvider,
      widget.linkColor,
      widget.hoverColor,
      widget.initialSelection,
    );

    int idx = -1;
    final m = Map<DataGridRow, int>.fromIterable(dataSource.rows, key: (e) => e, value: (e) {
      idx++;
      return idx;
    });

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (_, constraints) {
              return SfDataGridTheme(
                data: SfDataGridThemeData(
                  selectionColor: widget.selectionColor,
                ),
                child: SfDataGrid(
                  source: dataSource,
                  controller: _dataGridController,
                  headerRowHeight: DataGrid.rowHeight,
                  rowHeight: DataGrid.rowHeight,
                  selectionMode: selectionMode,
                  onSelectionChanged: (List<DataGridRow> addedRows, List<DataGridRow> removedRows) {
                    List<int> selectedIndexes = _dataGridController.selectedRows.map((e) => m[e]!).toList(growable: false);
                    if (widget.onSelectionChanged != null) {
                      widget.onSelectionChanged!(selectedIndexes);
                    }
                  },
                  columns: widget.columns
                      .map(
                        (e) => GridColumn(
                          width: widget.autoFit ? constraints.maxWidth * e.width / widget._totalWidth : e.width,
                          columnName: e.label,
                          label: InkWell(
                            onTap: e.sortable
                                ? () {
                                    if (widget.onSortChanged != null) {
                                      final newDirection = e.sortDirection == null
                                          ? SortDirection.ascending
                                          : (e.sortDirection == SortDirection.ascending)
                                              ? SortDirection.descending
                                              : SortDirection.ascending;
                                      widget.onSortChanged!(e.name, newDirection);
                                    }
                                  }
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: BaseWidget.inputBoxPadding),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Text(
                                    e.label,
                                    overflow: TextOverflow.clip,
                                    style: defaultTextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  e.sortDirection != null
                                      ? Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: Icon(
                                            e.sortDirection == SortDirection.ascending ? Icons.arrow_upward : Icons.arrow_downward,
                                            color: themeData.textTheme.caption?.color,
                                            size: 16,
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              );
            },
          ),
        ),
        const Divider(),
        widget.showPagination
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  widget.lastRefreshTime != null
                      ? Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            i18n.lastRefreshAt(widget.lastRefreshTime!),
                            style: defaultTextStyle(),
                          ),
                        )
                      : const SizedBox.shrink(),
                  SizedBox(
                    width: 250,
                    child: SfDataPager(
                      pageCount: 1,
                      availableRowsPerPage: const [50, 100, 200],
                      direction: Axis.horizontal,
                      onPageNavigationStart: (int pageIndex) {
                        //You can do your customization
                      },
                      // delegate: _dataGridSource(themeData),
                      delegate: dataSource,
                      onPageNavigationEnd: (int pageIndex) {
                        //You can do your customization
                      },
                      visibleItemsCount: 5,
                      itemWidth: 40,
                      itemHeight: 40,
                      navigationItemHeight: 40,
                      navigationItemWidth: 40,
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}

class DataGridRowWithItem<T> extends DataGridRow {
  late final T item;
  DataGridRowWithItem({
    required this.item,
    required List<DataGridCell> cells,
  }) : super(cells: cells);
}

class DataGridSourceImpl<T> extends DataGridSource with BaseWidget {
  late final List<T> items;
  late final List<DataGridColumn> columns;
  late final ValueFormatter<T> valueFormatter;
  late final ValueStyleProvider? valueStyleProvider;
  late final ActionProvider<T>? actionProvider;
  late final Color? selectionColor;
  late final Color? hoverColor;
  final List<int>? selectedIndexes;
  late final List<DataGridRow> dataGridRows;

  DataGridSourceImpl(
    this.items,
    this.columns,
    this.valueFormatter,
    this.valueStyleProvider,
    this.actionProvider,
    this.selectionColor,
    this.hoverColor,
    this.selectedIndexes,
  ) {
    dataGridRows = items.map((item) {
      final cells = columns
          .map(
            (column) => DataGridCell(
              columnName: column.name,
              value: valueFormatter(item, column.name),
            ),
          )
          .toList(growable: false);
      return DataGridRowWithItem(item: item, cells: cells);
    }).toList(growable: false);
  }

  @override
  List<DataGridRow> get rows {
    return dataGridRows;
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map((dataGridCell) {
        final customStyle = valueStyleProvider != null ? valueStyleProvider!(dataGridCell.value, dataGridCell.columnName) : null;
        final callBack = (actionProvider != null && row is DataGridRowWithItem) ? actionProvider!(row.item, dataGridCell.columnName) : null;
        final baseText = Text(
          dataGridCell.value.toString(),
          overflow: TextOverflow.ellipsis,
          style: defaultTextStyle(
            color: callBack != null ? selectionColor : null,
          ).merge(customStyle),
        );
        return Container(
          color: customStyle?.backgroundColor,
          margin: customStyle != null
              ? const EdgeInsets.only(
                  bottom: 1.0,
                )
              : null,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: BaseWidget.inputBoxPadding),
          child: callBack != null
              ? InkWell(
                  child: baseText,
                  onTap: () => callBack(),
                  hoverColor: hoverColor,
                )
              : baseText,
        );
      }).toList(),
    );
  }
}
