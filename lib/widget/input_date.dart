import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../util/logger.dart';
import 'base_widget.dart';

class InputDate extends StatefulWidget with BaseWidget, LabelledWidget {
  final String? label;
  final String? hint;
  final bool mandatory;
  final String? helperText;
  final Color? helpTextColor;
  final bool reserveHelperTextSpace;
  final TextEditingController controller;
  late final DateFormat _dateFormat;
  final bool enabled;
  final ValueChanged<DateTime?>? onChanged;

  InputDate({
    Key? key,
    this.label,
    this.hint,
    this.mandatory = false,
    this.helperText,
    this.helpTextColor,
    this.reserveHelperTextSpace = false,
    required this.controller,
    DateTime? initialValue,
    String dateFormat = 'yyyy-MM-dd',
    this.enabled = true,
    this.onChanged,
  }) : super(key: key) {
    _dateFormat = DateFormat(dateFormat);
    // If initialValue is provided, set it to controller text first
    if (initialValue != null) {
      final initialText = _dateFormat.format(initialValue);
      if (initialText != controller.text) {
        controller.text = initialText;
      }
    }
  }

  @override
  State<InputDate> createState() => _InputDateState();
}

class _InputDateState extends State<InputDate> {

  static const maxLength = 10;

  late FocusNode _focusNode;
  late FocusNode _iconFocusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        if (widget.controller.text.length != maxLength) {
          // clear the date field if not enough characters are entered
          _updateDate(null, null);
        }
      }
    });
    _iconFocusNode = FocusNode();
    _iconFocusNode.skipTraversal = true;
  }

  @override
  void dispose() {
    _iconFocusNode.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    final calendarIcon = widget.enabled
        ? InkWell(
            onTap: () async {
              DateTime? initialDate;
              try {
                initialDate = widget._dateFormat.parse(widget.controller.text);
              } on FormatException catch (_) {
                initialDate = DateTime.now();
              }

              final selectedDate = await showDatePicker(
                  context: context, firstDate: DateTime(1900), initialDate: initialDate, lastDate: DateTime(2100));
              logger.d('selectedDate = $selectedDate');
              if (selectedDate != null) {
                _updateDate(null, selectedDate);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: BaseWidget.iconPadding),
              child: Icon(
                Icons.calendar_today_outlined,
                color: themeData.textTheme.caption?.color,
              ),
            ),
            focusNode: _iconFocusNode,
          )
        : null;
    final iconConstraint = calendarIcon != null ? const BoxConstraints(maxHeight: BaseWidget.iconMaxHeight) : null;

    final clearIcon = !widget.enabled || widget.controller.text.isEmpty
        ? null
        : InkWell(
            onTap: () {
              widget.controller.clear();
              _updateDate('', null);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: BaseWidget.iconPadding),
              child: Icon(
                Icons.clear,
                color: themeData.textTheme.caption?.color,
              ),
            ),
            focusNode: _iconFocusNode,
          );
    final clearIconConstraint = clearIcon != null ? const BoxConstraints(maxHeight: BaseWidget.iconMaxHeight) : null;

    final baseTextField = TextField(
      style: const TextStyle(
        fontFamily: BaseWidget.fontFamily,
        fontWeight: FontWeight.normal,
        fontSize: BaseWidget.fontSize,
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(BaseWidget.inputBoxPadding),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
        ),
        filled: true,
        fillColor: widget.enabled ? themeData.inputDecorationTheme.fillColor : themeData.disabledColor,
        hintText: widget.hint,
        isDense: true,
        prefixIcon: calendarIcon,
        prefixIconConstraints: iconConstraint,
        suffixIcon: clearIcon,
        suffixIconConstraints: clearIconConstraint,
        helperText: widget.helperText,
        helperStyle: TextStyle(height: 0.5, color: widget.helpTextColor),
      ),
      controller: widget.controller,
      enabled: widget.enabled,
      inputFormatters: [
        _DateInputFormatter(widget._dateFormat),
      ],
      focusNode: _focusNode,
      onChanged: (value) => _updateDate(value, null),
    );

    final textField = widget.reserveHelperTextSpace && widget.helperText == null ? Padding(padding: const EdgeInsets.only(bottom: BaseWidget.helperTextAreaHeight), child: baseTextField,) : baseTextField;

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
              textField,
            ],
          )
        : textField;
  }

  void _updateDate(String? dateEntered, DateTime? dateSelected) {

    DateTime? newDateValue = dateSelected;
    if (dateSelected != null) {
      // a date is selected
      widget.controller.text = widget._dateFormat.format(dateSelected);
    }
    else if (dateEntered == null || dateEntered.isEmpty) {
      // the date value is clear
      widget.controller.text = '';
    }
    else {
      // check if valid date value is entered
      final reqLengthOfCharEntered = dateEntered.length == widget._dateFormat.pattern?.length;
      if (reqLengthOfCharEntered && newDateValue == null) {
        try {
          newDateValue = widget._dateFormat.parse(dateEntered);
        } on FormatException catch (_) {
          logger.i('Invalid dateString = $dateEntered');
        }
      }
    }

    // show or hide the clear icon
    setState(() {
      if (widget.onChanged != null) {
        if (newDateValue != null) {
          // a valid date is selected or entered
          widget.onChanged!(newDateValue);
        }
        else if (dateEntered != null && dateEntered.isEmpty) {
          // the date value is clear
          widget.onChanged!(null);
        }
      }
    });
  }
}

class _DateInputFormatter extends TextInputFormatter {
  static final nonNumericPattern = RegExp(r'[^0-9]');
  static final separatorPattern = RegExp(r'[^yMd]');

  final DateFormat _dateFormat;

  _DateInputFormatter(this._dateFormat);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {

    // Short-circuit if the new value is empty
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String oldValueText = oldValue.text;
    String newValueText = newValue.text;

    final maxLength = _dateFormat.pattern!.length;
    final pattern = _dateFormat.pattern!;
    final firstSeparatorIdx = pattern.indexOf(separatorPattern);
    final secondSeparatorIdx = pattern.indexOf(separatorPattern, firstSeparatorIdx + 1);

    if (newValueText.length > maxLength) {
      newValueText = newValueText.substring(0, maxLength);
    }
    // Remove everything after the cursor
    newValueText = newValueText.substring(0, newValue.selection.baseOffset);
    if (newValueText.lastIndexOf(nonNumericPattern) == newValueText.length - 1) {
      // If ends with separator, remove it
      newValueText = newValueText.substring(0, newValueText.length - 1);
    }
    final newValueLength = newValueText.length;

    if (newValueLength > maxLength) {
      // Excess character is entered, discard
      newValueText = oldValueText;
    }

    if (newValueLength >= maxLength) {
      try {
        final parsedDateTime = _dateFormat.parse(newValueText);
        if (_dateFormat.format(parsedDateTime) != newValueText) {
          newValueText = oldValueText;
        }
      } on Exception catch(_) {
        logger.i('$newValueText is not an valid date');
        newValueText = oldValueText;
      }
    }

    // Only process if the old value and new value are different
    if (oldValueText != newValueText) {

      String newString = '';

      if (newValueLength <= firstSeparatorIdx) {
        // Y or YY or YYY or YYYY
        newString = newValueText;
      }
      else if (newValueLength == firstSeparatorIdx + 1) {
        // YYYYM => YYYY-M
        newString = newValueText.substring(0, firstSeparatorIdx) + pattern.substring(firstSeparatorIdx, firstSeparatorIdx + 1) + newValueText.substring(firstSeparatorIdx);
      }
      else if (newValueLength <= secondSeparatorIdx) {
        // YYYY-M or YYYY-MM
        newString = newValueText;
      }
      else if (newValueLength == secondSeparatorIdx + 1) {
        // YYYY-MMD => YYYY-MM-D
        newString = newValueText.substring(0, secondSeparatorIdx) + pattern.substring(secondSeparatorIdx, secondSeparatorIdx + 1) + newValueText.substring(secondSeparatorIdx);
      }
      else {
        // YYYY-MM-DD
        newString = newValueText;
      }

      int selectionIndex = newValueLength - newValue.selection.extentOffset;
      return TextEditingValue(
        text: newString.toString(),
        selection: TextSelection.collapsed(
          offset: selectionIndex > newString.length ? newString.length : newString.length - selectionIndex,
        ),
      );
    }

    // If the new value and old value are the same, just return as-is
    return oldValue;
  }
}