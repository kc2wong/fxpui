import 'package:flutter/material.dart';

import 'base_widget.dart';

class InputText extends StatefulWidget with BaseWidget, LabelledWidget {
  final String? label;
  final String? labelSuffix;
  final String? hint;
  final bool mandatory;
  final String? helperText;
  final Color? helpTextColor;
  final String? errorText;
  final String? prefixText;
  final String? tooltip;
  final bool reserveHelperTextSpace;
  final int? maxLines;
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String?>? onChanged;
  final ValueChanged<String?>? onEditCompleted;

  InputText({
    Key? key,
    this.label,
    this.labelSuffix,
    this.hint,
    this.mandatory = false,
    this.prefixText,
    this.tooltip,
    this.helperText,
    this.reserveHelperTextSpace = false,
    this.helpTextColor,
    this.errorText,
    this.maxLines = 1,
    String? initialValue,
    required this.controller,
    this.enabled = true,
    this.onChanged,
    this.onEditCompleted,
  }) : super(key: key) {
    if (initialValue != null) {
      if (initialValue != controller.text) {
        controller.text = initialValue;
      }
    }
  }

  @override
  State<InputText> createState() => _InputTextState();
}

class _InputTextState extends State<InputText> {
  late FocusNode _focusNode;
  late FocusNode _clearIconFocusNode;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && widget.onEditCompleted != null) {
        String newValue = widget.controller.text;
        widget.onEditCompleted!(newValue.isEmpty ? null : newValue);
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

    final clearIcon = !widget.enabled || widget.controller.text.isEmpty
        ? null
        : InkWell(
            onTap: () {
              widget.controller.clear();
              // hide the clear icon
              setState(() {
                if (widget.onEditCompleted != null) {
                  widget.onEditCompleted!(null);
                }
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
        filled: true,
        fillColor: widget.enabled ? themeData.inputDecorationTheme.fillColor : themeData.disabledColor,
        isDense: true,
        prefixIcon: prefix,
        prefixIconConstraints: prefixConstraint,
        suffixIconConstraints: clearIconConstraint,
        suffixIcon: clearIcon,
        hintText: widget.hint,
        helperText: widget.errorText ?? widget.helperText,
        errorText: widget.errorText,
        helperStyle: TextStyle(height: 0.5, color: widget.helpTextColor),
        errorStyle: TextStyle(height: 0.5, color: themeData.errorColor),
      ),
      maxLines: widget.maxLines,
      controller: widget.controller,
      onChanged: (value) {
        setState(() {
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
        });
      },
      focusNode: _focusNode,
      enabled: widget.enabled,
      onEditingComplete: () {
        _focusNode.nextFocus();
      },
    );
    final textField = widget.reserveHelperTextSpace && widget.helperText == null && widget.errorText == null
        ? Padding(
            padding: const EdgeInsets.only(bottom: BaseWidget.helperTextAreaHeight),
            child: baseTextField,
          )
        : baseTextField;

    if (widget.label != null) {
      final label = widget.constructLabel(
        widget.label!,
        widget.mandatory,
        themeData,
        suffix: widget.labelSuffix,
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: BaseWidget.labelPadding),
            child: widget.tooltip != null
                ? widget.addTooltip(
                    themeData,
                    widget.tooltip!,
                    label,
                  )
                : label,
          ),
          textField,
        ],
      );
    }
    else {
      return widget.tooltip != null
          ? widget.addTooltip(
              themeData,
              widget.tooltip!,
              textField,
            )
          : textField;
    }
  }
}
