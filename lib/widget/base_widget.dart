import 'package:flutter/material.dart';

abstract class BaseWidget {
  static const fontFamily = 'SegoeUI';
  static const fontSize = 14.0;

  // padding inside the textBox
  static const inputBoxPadding = 10.0;
  // padding inside the textBox
  static const iconPadding = 10.0;
  // Vertical padding between the label and textBox
  static const labelPadding = 5.0;

  static const iconSize = 16.0;
  static const iconMaxHeight = 25.0;

  // Extra padding when there is no helper text
  static const helperTextAreaHeight = 14.0;

  static const filler = SizedBox.shrink();

  TextStyle defaultTextStyle({Color? color, Color? backgroundColor, FontWeight? fontWeight, double? fontSize}) {
    return TextStyle(
      fontWeight: fontWeight ?? FontWeight.normal,
      fontSize: fontSize ?? BaseWidget.fontSize,
      color: color,
      backgroundColor: backgroundColor,
    );
  }

  Widget addTooltip(ThemeData themeData, String tooltip, Widget widget) {
    return Tooltip(
      message: tooltip,
      child: widget,
      textStyle: defaultTextStyle(),
      decoration: BoxDecoration(
        color: themeData.secondaryHeaderColor,
      ),
    );
  }
}

class LabelledWidget {
  Widget constructLabel(
    String label,
    bool mandatory,
    ThemeData? themeData, {
    String? suffix,
  }) {
    final baseTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: BaseWidget.fontSize,
      color: themeData ?.textTheme.labelMedium?.color,
    );

    List<TextSpan> children = [];
    if (mandatory) {
      children.add(
        TextSpan(
          text: ' * ',
          style: baseTextStyle.copyWith(color: Colors.red),
        ),
      );
    }
    if (suffix != null) {
      children.add(
        TextSpan(
          text: suffix,
          style: baseTextStyle,
        ),
      );
    }
    return RichText(
      text: TextSpan(
        text: label,
        style: baseTextStyle,
        children: children,
      ),
    );
  }
}