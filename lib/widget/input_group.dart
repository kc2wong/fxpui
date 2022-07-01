import 'package:flutter/material.dart';

import 'base_widget.dart';

enum InputGroupLayoutDirection {
  vertical,
  horizontal,
}

class InputGroup extends StatelessWidget with BaseWidget, LabelledWidget {
  // Padding between each row
  static const rowPadding = EdgeInsets.all(8.0);

  final String label;
  final String? helperText;
  final String? errorText;
  final Color? helpTextColor;
  final bool mandatory;
  final Color? backgroundColor;
  final bool reserveHelperTextSpace;
  final String? tooltip;
  final List<Widget> widgets;

  const InputGroup({
    Key? key,
    required this.label,
    required this.widgets,
    this.helperText,
    this.helpTextColor,
    this.mandatory = false,
    this.backgroundColor,
    this.reserveHelperTextSpace = false,
    this.tooltip,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    final widgetList = widgets
        .map(
          (e) => Padding(
            padding: rowPadding,
            child: e,
          ),
        )
        .toList(growable: false);

    final labelWidget = constructLabel(
      label,
      mandatory,
      themeData,
    );

    final stack = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.only(top: 6, left: 4, right: 4, bottom: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.zero,
            border: Border.all(
                color: errorText != null ? themeData.errorColor : themeData.inputDecorationTheme.border!.borderSide.color),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widgetList,
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            margin: const EdgeInsets.only(left: 8.0),
            color: backgroundColor ?? themeData.backgroundColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: tooltip != null ? addTooltip(themeData, tooltip!, labelWidget) : labelWidget,
            ),
          ),
        ),
      ],
    );

    if (errorText != null) {
      final text = Padding(
        // padding of label = 16, add extra 8
        padding: const EdgeInsets.only(left: 20.0),
        child: Text(
          errorText!,
          style: themeData.inputDecorationTheme.helperStyle?.copyWith(color: themeData.errorColor),
        ),
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          stack,
          text,
        ],
      );
    } else if (helperText != null) {
      final text = Padding(
        // padding of label = 16, add extra 8
        padding: const EdgeInsets.only(left: 20.0),
        child: Text(
          helperText!,
          style: themeData.inputDecorationTheme.helperStyle?.copyWith(color: helpTextColor),
        ),
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          stack,
          text,
        ],
      );
    } else {
      if (reserveHelperTextSpace) {
        final Size size = (TextPainter(
            text: TextSpan(text: '', style: themeData.inputDecorationTheme.helperStyle),
            maxLines: 1,
            textScaleFactor: MediaQuery
                .of(context)
                .textScaleFactor,
            textDirection: TextDirection.ltr)
          ..layout())
            .size;

        return Padding(
          padding: EdgeInsets.only(bottom: size.height + 2),
          child: stack,
        );
      } else {
        return stack;
      }
    }
  }
}
