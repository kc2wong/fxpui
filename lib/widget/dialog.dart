import 'package:flutter/material.dart';

import 'base_widget.dart';
import 'button.dart';

class YesNoDialogButtonProp {
  String label;
  Icon? icon;
  VoidCallback? action;

  YesNoDialogButtonProp(
    this.label, {
    this.action,
    this.icon,
  });
}

class YesNoDialog extends StatelessWidget with BaseWidget {
  final String title;
  final String subText;
  final Widget? detail;
  final YesNoDialogButtonProp yesButtonProp;
  final YesNoDialogButtonProp noButtonProp;

  const YesNoDialog({
    Key? key,
    required this.title,
    required this.subText,
    this.detail,
    required this.yesButtonProp,
    required this.noButtonProp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final text = Text(
      subText,
      style: defaultTextStyle(),
    );

    return AlertDialog(
      title: Text(title),
      titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      actionsPadding: const EdgeInsets.only(
        right: 12,
        bottom: 12,
      ),
      actions: [
        Button(
          buttonType: ButtonType.primary,
          text: yesButtonProp.label,
          onTap: () {
            if (yesButtonProp.action != null) {
              yesButtonProp.action!();
            }
            Navigator.of(context).pop(true);
          },
        ),
        Button(
          buttonType: ButtonType.secondary,
          text: noButtonProp.label,
          onTap: () {
            if (noButtonProp.action != null) {
              noButtonProp.action!();
            }
            Navigator.of(context).pop(false);
          },
        ),
      ],
      content: detail != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                detail!,
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Divider(
                    thickness: 2,
                  ),
                ),
                text,
              ],
            )
          : text,
    );
  }
}
