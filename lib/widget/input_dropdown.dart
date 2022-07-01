import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import '../util/logger.dart';
import 'base_widget.dart';

typedef ChangeConfirmation<T> = Future<bool> Function(List<T> items);

class InputDropdown<T> extends StatefulWidget with BaseWidget, LabelledWidget {
  final String? label;
  final String? hint;
  final bool multipleSelection;
  final bool mandatory;
  final bool showSearchBox;
  final bool enabled;

  // Key is description
  late final Map<String, T> choices;

  final TextEditingController controller;
  final ValueChanged<List<T>>? onChanged;
  final ChangeConfirmation<T>? changeConfirmation;
  final String? helperText;
  final Color? helperTextColor;
  final bool reserveHelperTextSpace;

  InputDropdown({
    Key? key,
    this.label,
    this.hint,
    this.multipleSelection = false,
    this.mandatory = false,
    this.showSearchBox = false,
    this.enabled = true,
    this.helperText,
    this.reserveHelperTextSpace = false,
    this.helperTextColor,
    required this.controller,
    this.onChanged,
    this.changeConfirmation,
    List<T>? initialValue,
    required Map<T, String> choices, // Value - Description pair
  }) : super(key: key) {
    this.choices = {
      for (var e in choices.entries) e.value: e.key,
    };
    // Text in controller is the source of selected item.  If initialValue is provided, set it to controller text first
    if (initialValue != null) {
      final initialText = initialValue.map((e) => choices[e]).join(', ');
      if (initialText != controller.text) {
        controller.text = initialText;
      }
    }
  }

  @override
  State<InputDropdown> createState() => _InputDropdownState<T>();
}

class _InputDropdownState<T> extends State<InputDropdown<T>> {
  final _dropdownSearchKey = GlobalKey<DropdownSearchState<T>>();
  late FocusNode _dropdownButtonFocusNode;

  @override
  void initState() {
    super.initState();
    _dropdownButtonFocusNode = FocusNode();
    _dropdownButtonFocusNode.addListener(() {
      if (_dropdownButtonFocusNode.hasFocus) {
        _dropdownButtonFocusNode.nextFocus();
      }
    });
  }

  @override
  void dispose() {
    _dropdownButtonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    const clearIconConstraint = BoxConstraints(maxHeight: BaseWidget.iconMaxHeight);

    const scrollbarProps = ScrollbarProps(
      // isAlwaysShown: false,
    );

    // TextBox to show selected item and dropdown icon
    final dropdownSearchDecoration = InputDecoration(
      // background color
      fillColor: widget.enabled ? themeData.inputDecorationTheme.fillColor : themeData.disabledColor,
      filled: true,
      contentPadding: const EdgeInsets.all(BaseWidget.inputBoxPadding),
      isDense: true,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
      ),
      helperText: widget.helperText,
      helperStyle: TextStyle(height: 0.5, color: widget.helperTextColor),
      suffixIconConstraints: clearIconConstraint,
    );

    final searchFieldProps = TextFieldProps(
      autofocus: true,
      style: widget.defaultTextStyle(),
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.all(BaseWidget.inputBoxPadding),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
    );

    final items = widget.choices.values.toList(
      growable: false,
    );

    final baseDropdown = widget.multipleSelection
        ? DropdownSearch<T>.multiSelection(
            key: _dropdownSearchKey,
            enabled: widget.enabled,
            selectedItems: widget.controller.text.isEmpty ? [] : widget.controller.text.split(',').map((e) => e.trim()).map((e) => widget.choices[e]!).toList(growable: false),
            popupProps: PopupPropsMultiSelection.menu(
              showSearchBox: widget.showSearchBox,
              showSelectedItems: false,
              searchFieldProps: searchFieldProps,
              itemBuilder: (_, item, isSelected) => _popupItemBuilder(themeData, item, isSelected),
              onItemAdded: (currentList, _) {
                _dropdownSearchKey.currentState?.changeSelectedItems(currentList);
              },
              onItemRemoved: (_, item) {
                _dropdownSearchKey.currentState?.removeItem(item);
              },
              validationWidgetBuilder: (context, list) {
                // Hide the OK button
                return Container();
              },
              selectionWidget: (_, item, isSelected) => _popupSelectionWidget(themeData, isSelected),
              scrollbarProps: scrollbarProps,
            ),
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: dropdownSearchDecoration,
            ),
            clearButtonProps: _clearButtonBuilder(themeData, !widget.mandatory),
            dropdownButtonProps: _dropdownButtonBuilder(themeData),
            dropdownBuilder: (_, items) {
              // If no item is selected, display the hint.  If items are selected, concat with ","
              // final textContent = items.isEmpty ? widget.hint ?? '' : items.join(', ');
              final textContent = items.isEmpty ? widget.hint ?? '' : widget.choices.entries.where((element) => items.contains(element.value)).map((e) => e.key).join(', ');
              return Text(
                textContent,
                style: widget.defaultTextStyle(color: items.isEmpty ? themeData.hintColor : null),
                overflow: TextOverflow.fade,
                softWrap: false,
              );
            },
            items: items,
            onBeforeChange: widget.changeConfirmation == null ? null : (prevItems, nextItems) => widget.changeConfirmation!(nextItems),
            onChanged: (items) {
              final text = widget.choices.entries.where((element) => items.contains(element.value)).map((e) => e.key).join(', ');
              logger.d('Selected items = $text}');
              widget.controller.text = text;
              if (widget.onChanged != null) {
                widget.onChanged!(items);
              }
            },
          )
        : DropdownSearch<T>(
            enabled: widget.enabled,
            popupProps: PopupProps.menu(
              showSelectedItems: false,
              showSearchBox: widget.showSearchBox,
              searchFieldProps: searchFieldProps,
              scrollbarProps: scrollbarProps,
              itemBuilder: (_, item, isSelected) => _popupItemBuilder(themeData, item, isSelected),
            ),
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: dropdownSearchDecoration,
            ),
            clearButtonProps: _clearButtonBuilder(themeData, !widget.mandatory),
            dropdownButtonProps: _dropdownButtonBuilder(themeData),
            dropdownBuilder: (_, item) {
              final textContent = item == null ? widget.hint ?? '' : widget.choices.entries.firstWhere((element) => element.value == item).key;
              return Text(
                textContent,
                style: widget.defaultTextStyle(
                  color: item == null ? themeData.hintColor : null,
                ),
                overflow: TextOverflow.fade,
              );
            },
            items: items,
            onBeforeChange: widget.changeConfirmation == null
                ? null
                : (prevItem, nextItem) => widget.changeConfirmation!(nextItem != null ? [nextItem] : []),
            onChanged: (item) {
              final text = item == null ? '' : widget.choices.entries.firstWhere((element) => element.value == item).key;
              logger.d('Selected items = $text}');
              widget.controller.text = text;
              if (widget.onChanged != null) {
                widget.onChanged!(item == null ? [] : [item]);
              }
            },
            selectedItem: widget.controller.text.isNotEmpty ? widget.choices[widget.controller.text] : null,
          );

    final dropdown = widget.reserveHelperTextSpace && widget.helperText == null
        ? Padding(
            padding: const EdgeInsets.only(bottom: BaseWidget.helperTextAreaHeight),
            child: baseDropdown,
          )
        : baseDropdown;

    return widget.label != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: BaseWidget.labelPadding),
                child: widget.constructLabel(
                  widget.label!,
                  widget.mandatory,
                  themeData,
                ),
              ),
              dropdown,
            ],
          )
        : dropdown;
  }

  ClearButtonProps _clearButtonBuilder(ThemeData themeData, bool visible) => ClearButtonProps(
    isVisible: visible,
    icon: Icon(
      Icons.clear,
      color: themeData.textTheme.caption?.color,
    ),
    padding: const EdgeInsets.only(),
    splashRadius: 1,
    iconSize: 18,
    // Make the clear button closed to the dropdown
    constraints: const BoxConstraints(maxWidth: 10),
  );

  DropdownButtonProps _dropdownButtonBuilder(ThemeData themeData) => DropdownButtonProps(
    icon: Icon(
      Icons.keyboard_arrow_down,
      color: themeData.textTheme.caption?.color,
    ),
    focusNode: _dropdownButtonFocusNode,
    padding: const EdgeInsets.only(),
    splashRadius: 1,
  );

  // Item to show in dropdown popup for selection
  Widget _popupItemBuilder(ThemeData themeData, T? item, bool isSelected) => Container(
        color: isSelected ? themeData.highlightColor : null,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          dense: true,
          selected: isSelected,
          // When value is -4, there will be some white area on top and bottom (height of checkbox is higher
          // not sure why
          visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
          title: Text(
            item == null ? '' : widget.choices.entries.firstWhere((element) => element.value == item).key,
            style: widget.defaultTextStyle(
              color: isSelected ? themeData.textTheme.caption?.color : null,
              fontWeight: isSelected ? FontWeight.bold : null,
            ),
          ),
        ),
      );

  // Checkbox adjacent to the selection item in multi select dropdown
  Widget _popupSelectionWidget(ThemeData themeData, bool isSelected) => Checkbox(
    value: isSelected,
    onChanged: (_) {},
  );
}
