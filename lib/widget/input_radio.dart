import 'package:flutter/material.dart';

import '../util/logger.dart';
import 'base_widget.dart';

class InputRadio<T> extends StatefulWidget with BaseWidget, LabelledWidget {
  final String label;
  final TextEditingController controller;
  final bool horizontal;
  final bool mandatory;
  final T? initialValue;
  final ValueChanged<T?>? onChanged;
  // Key is description
  late final Map<String, T> choices;

  InputRadio({
    Key? key,
    required this.label,
    required this.controller,
    this.horizontal = false,
    this.mandatory = false,
    this.initialValue,
    this.onChanged,
    required Map<T, String> choices,
  }) : super(key: key) {
    this.choices = {
      for (var e in choices.entries) e.value: e.key,
    };
  }

  @override
  State<InputRadio<T>> createState() => _InputRadioState<T>();
}

class _InputRadioState<T> extends State<InputRadio<T>> {
  T? selectedValue;

  @override
  Widget build(BuildContext context) {
    logger.d('text = ${widget.controller.text}');
    final radioButtons = widget.choices.entries
        .map(
          (e) => Expanded(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              minLeadingWidth: 0,
              leading: Transform.translate(
                offset: const Offset(-4, 0),
                child: Radio<T>(
                  visualDensity: const VisualDensity(
                    horizontal: VisualDensity.minimumDensity,
                  ),
                  // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  splashRadius: 16.0,
                  value: e.value,
                  groupValue: selectedValue ?? widget.initialValue,
                  onChanged: _valueChanged,
                ),
              ),
              title: Transform.translate(
                offset: const Offset(-12, 0),
                child: InkWell(
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: () {
                    _valueChanged(e.value);
                  },
                  child: Text(
                    e.key,
                    style: widget.defaultTextStyle(),
                  ),
                ),
              ),
            ),
          ),
        )
        .toList(growable: false);

    final labelWidget = widget.constructLabel(
      widget.label,
      widget.mandatory,
      Theme.of(context),
    );
    const padding = SizedBox(
      height: 5,
    );
    if (widget.horizontal) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          labelWidget,
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: radioButtons,
          ),
          padding,
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[labelWidget, ...radioButtons, padding],
      );
    }
  }

  void _valueChanged(T? value) {
    widget.controller.text = value != null ? widget.choices.entries.where((element) => element.value == value).first.key : '';
    selectedValue = value;
    setState(() {
      if (widget.onChanged != null) {
        widget.onChanged!(value);
      }
    });
  }
}
