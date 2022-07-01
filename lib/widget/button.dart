import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widget/base_widget.dart';

enum ButtonType {
  primary,
  secondary,
  textOnly,
  iconOnly,
}

class Button extends StatelessWidget with BaseWidget {
  static const defaultIconSize = 18.0;

  final ButtonType buttonType;
  final VoidCallback? onTap;
  final String text;
  final Icon? icon;
  final Color? hoverColor;
  final double minHeight;
  final double minWidth;

  const Button({
    Key? key,
    this.buttonType = ButtonType.secondary,
    required VoidCallback onTap,
    required this.text,
    this.icon,
    this.hoverColor,
    this.minHeight = 40,
    this.minWidth = 80,
    enabled = true,
  })  : assert(buttonType != ButtonType.iconOnly || icon != null),
        onTap = enabled ? onTap : null,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    // Primary Button
    // Light Theme -> Primary Color as background and border, white (Text Color of Dark Theme) text
    // Dark Theme -> Primary Color as background and border, black (Text Color Light Theme) text

    // Secondary Button
    // Light Theme -> No background color, default border, black (Text Color of Light Theme) text, Primary color icon
    // Dark Theme -> Primary Color as background and border, white (Text Color Dark Theme) text, Primary color icon

    final backgroundColor = buttonType == ButtonType.primary && onTap != null ? themeData.primaryColor : null;
    final borderColor = onTap == null
        ? null
        : buttonType == ButtonType.primary
        ? themeData.primaryColor
        : buttonType == ButtonType.secondary
        ? themeData.inputDecorationTheme.border!.borderSide.color
        : null;
    final primaryTextColor = onTap == null
        ? null
        : themeData.brightness == Brightness.light
        ? AppTheme.dark.textTheme.bodyText1?.color
        : AppTheme.light.textTheme.bodyText1?.color;
    final secondaryTextColor = onTap == null
        ? null
        : themeData.textTheme.bodyText1?.color;

    final buttonStyle = ButtonStyle(
      backgroundColor: backgroundColor != null ? MaterialStateProperty.all(backgroundColor) : null,
      shape: MaterialStateProperty.all(
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(
              2.0,
            ),
          ),
        ),
      ),
      minimumSize: MaterialStateProperty.all<Size>(
        Size(
          minWidth,
          minHeight,
        ),
      ),
      side: borderColor != null
          ? MaterialStateProperty.all(
              BorderSide(color: borderColor),
            )
          : null,
      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
        const EdgeInsets.symmetric(horizontal: 12.0),
      ),
    );

    switch (buttonType) {
      case ButtonType.primary:
        final label = Text(
          text,
          style: defaultTextStyle(color: onTap == null ? null : primaryTextColor),
        );
        if (icon != null) {
          return ElevatedButton.icon(
            icon: Icon(
              icon!.icon,
              size: icon!.size ?? defaultIconSize,
              color: primaryTextColor,
            ),
            label: label,
            style: buttonStyle,
            onPressed: onTap,
          );
        } else {
          return ElevatedButton(
            style: buttonStyle,
            onPressed: onTap,
            child: label,
          );
        }
      case ButtonType.secondary:
        final label = Text(
          text,
          style: defaultTextStyle(
            // color: onTap != null ? themeData.textTheme.labelMedium?.color : null,
            color: secondaryTextColor,
          ),
        );
        if (icon != null) {
          return OutlinedButton.icon(
            icon: Icon(
              icon!.icon,
              size: icon!.size ?? defaultIconSize,
            ),
            label: label,
            style: buttonStyle,
            onPressed: onTap,
          );
        } else {
          return OutlinedButton(
            style: buttonStyle,
            onPressed: onTap,
            child: label,
          );
        }
      case ButtonType.textOnly:
        final label = Text(
          text,
          style: defaultTextStyle(),
        );
        if (icon != null) {
          return TextButton.icon(
            onPressed: onTap,
            icon: icon!,
            label: label,
          );
        } else {
          return TextButton(
            onPressed: onTap,
            child: label,
          );
        }
      case ButtonType.iconOnly:
        return Tooltip(
          message: text,
          decoration: BoxDecoration(
            color: themeData.secondaryHeaderColor,
          ),
          textStyle: defaultTextStyle(),
          child: IconButton(
            icon: icon!,
            hoverColor: hoverColor,
            onPressed: onTap,
            color: themeData.primaryColor,
            splashRadius: 16.0,
          ),
        );
    }
  }
}
