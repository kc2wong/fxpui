import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'base_widget.dart';
import '../util/logger.dart';

class InputNumber extends StatefulWidget with BaseWidget, LabelledWidget {
  static const separator = ',';
  static const decimalPoint = '.';

  final String? label;
  final String? hint;
  final bool mandatory;
  final String? helperText;
  final Color? helpTextColor;
  final String? errorText;
  final String? prefixText;
  final bool reserveHelperTextSpace;
  final bool thousandSeparator;
  final bool allowNegative;
  final int numberOfDecimal;
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<double?>? onChanged;

  InputNumber({
    Key? key,
    this.label,
    this.hint,
    this.mandatory = false,
    this.prefixText,
    this.helperText,
    this.reserveHelperTextSpace = false,
    this.helpTextColor,
    this.errorText,
    this.thousandSeparator = true,
    this.allowNegative = true,
    this.numberOfDecimal = 0,
    double? initialValue,
    required this.controller,
    this.enabled = true,
    this.onChanged,
  }) : super(key: key) {
    logger.d('Create InputNumber $label, initialValue = $initialValue content = ${controller.text}, numberOfDecimal = $numberOfDecimal');
    if (initialValue != null) {
      final integerPart = thousandSeparator ? '#,###' : '#';
      final decimalPart = numberOfDecimal > 0 ? '.' + '0' * numberOfDecimal : '';
      final initialText = NumberFormat('$integerPart$decimalPart').format(initialValue);
      if (initialText != controller.text) {
        controller.text = initialText;
      }
    }
    else {
      // truncate decimal point if necessary
      final idx = controller.text.indexOf(decimalPoint);
      final dp = idx == -1 ? 0 : controller.text.length - (controller.text.indexOf(decimalPoint) + 1);
      if (dp > numberOfDecimal) {
        controller.text = controller.text.substring(0, controller.text.length - (dp - numberOfDecimal));
        if (controller.text.endsWith(decimalPoint)) {
          controller.text = controller.text.substring(0, controller.text.length - 1);
        }
      }
    }
  }

  @override
  State<InputNumber> createState() => _InputNumberState();
}

class _InputNumberState extends State<InputNumber> {

  late FocusNode _focusNode;
  late FocusNode _clearIconFocusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && widget.controller.text.isNotEmpty) {
        String newValue = widget.controller.text;

        final integerPart = widget.thousandSeparator ? '#,###' : '#';
        final decimalPart = widget.numberOfDecimal > 0 ? '.' + '0' * widget.numberOfDecimal : '';
        newValue = NumberFormat('$integerPart$decimalPart').format(double.parse(newValue.replaceAll(',', '')));

        if (widget.controller.text != newValue) {
          widget.controller.text = newValue;
        }
      }
    });
    _clearIconFocusNode = FocusNode();
    _clearIconFocusNode.skipTraversal = true;
  }

  @override
  void dispose() {
    _clearIconFocusNode.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    final clearIcon = widget.controller.text.isEmpty
        ? null
        : InkWell(
            onTap: () {
              widget.controller.clear();
              // hide the clear icon
              setState(() {
                if (widget.onChanged != null) {
                  widget.onChanged!(null);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: BaseWidget.iconPadding),
              child: Icon(
                Icons.clear,
                color: themeData.textTheme.caption?.color,
              ),
            ),
            focusNode: _clearIconFocusNode,
          );

    final clearIconConstraint = widget.controller.text.isEmpty ? null : const BoxConstraints(maxHeight: BaseWidget.iconMaxHeight);

    final prefix = widget.prefixText != null
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              widget.prefixText!,
              textAlign: TextAlign.center,
              style: widget.defaultTextStyle(
                color: themeData.textTheme.labelMedium?.color,
              ),
            ),
          )
        : null;
    final prefixConstraint = widget.prefixText != null ? const BoxConstraints(maxHeight: BaseWidget.iconMaxHeight) : null;

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
        hintText: widget.hint,
        filled: true,
        fillColor: widget.enabled ? themeData.inputDecorationTheme.fillColor : themeData.disabledColor,
        isDense: true,
        helperText: widget.errorText ?? widget.helperText,
        errorText: widget.errorText,
        helperStyle: TextStyle(height: 0.5, color: widget.helpTextColor),
        errorStyle: TextStyle(height: 0.5, color: themeData.errorColor),
        prefixIcon: prefix,
        prefixIconConstraints: prefixConstraint,
        suffixIconConstraints: clearIconConstraint,
        suffixIcon: clearIcon,
      ),
      controller: widget.controller,
      inputFormatters: [
        _ThousandsSeparatorInputFormatter(InputNumber.separator, widget.numberOfDecimal, widget.allowNegative),
      ],
      focusNode: _focusNode,
      onChanged: (value) {
        // update the clear icon
        setState(() {
          final doubleValue = double.tryParse(value.replaceAll(InputNumber.separator, ''));
          if (value.isEmpty || doubleValue != null) {
            // field is cleared, or a valid number is entered
            if (widget.onChanged != null) {
              widget.onChanged!(doubleValue);
            }
          }
        });
      },
    );

    final textField = widget.reserveHelperTextSpace && widget.helperText == null && widget.errorText == null
        ? Padding(
            padding: const EdgeInsets.only(bottom: BaseWidget.helperTextAreaHeight),
            child: baseTextField,
          )
        : baseTextField;

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
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {

  static const decimalPoint = InputNumber.decimalPoint;

  final String separator;
  final int decimalPlace;
  final bool allowNegative;

  _ThousandsSeparatorInputFormatter(this.separator, this.decimalPlace, this.allowNegative);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {

    final isNegative = newValue.text.startsWith('-');

    // Short-circuit if the new value is empty
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Handle "deletion" of separator character
    String oldValueText = oldValue.text.replaceAll(separator, '');
    String newValueText = newValue.text.replaceAll(separator, '');

    if (double.tryParse(newValueText + '0') == null) {
      // invalid value is entered
      newValueText = oldValueText;
    } else if (newValue.text.endsWith(decimalPoint) && decimalPlace == 0) {
      // decimal point not allowed if number of decimal place is 0
      newValueText = oldValueText;
    } else if (oldValue.text.endsWith(separator) && oldValue.text.length == newValue.text.length + 1) {
      newValueText = newValueText.substring(0, newValueText.length - 1);
    }

    final oldToken = oldValueText.split(decimalPoint);
    oldValueText = oldToken[0];
    String oldDecimalValueText = oldToken.length > 1 ? oldToken[1] : '';

    final newToken = newValueText.split(decimalPoint);
    newValueText = newToken[0];
    String newDecimalValueText = newToken.length > 1 ? newToken[1] : '';

    // Do the formatting
    // Only process if the old value and new value are different, and contain valid decimal place
    if ((oldValueText != newValueText || oldDecimalValueText != newDecimalValueText || oldToken.length != newToken.length) && newDecimalValueText.length <= decimalPlace) {
      int selectionIndex =
          newValue.text.length - newValue.selection.extentOffset;
      final chars = newValueText.replaceAll('-','').split('');

      String newString = '';
      for (int i = chars.length - 1; i >= 0; i--) {
        if ((chars.length - 1 - i) % 3 == 0 && i != chars.length - 1) {
          newString = separator + newString;
        }
        newString = chars[i] + newString;
      }

      if (allowNegative && isNegative) {
        // restore the negative sign
        newString = '-' + newString;
      }
      if (newToken.length > 1) {
        // restore the decimal value
        newString = newString + decimalPoint + newDecimalValueText;
      }

      return TextEditingValue(
        text: newString.toString(),
        selection: TextSelection.collapsed(
          offset: newString.length - selectionIndex ,
        ),
      );
    }

    // If the new value and old value are the same, just return as-is
    return oldValue;
  }
}
