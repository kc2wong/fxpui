import 'package:flutter/material.dart';

import 'base_widget.dart';
import 'on_hover.dart';

class DropDownButtonAction {
  final VoidCallback action;
  final String text;
  final bool checked;

  DropDownButtonAction(
    this.action,
    this.text, {
    this.checked = false,
  });
}

class DropDownButton extends StatelessWidget with BaseWidget {

  static const defaultIconSize = 18.0;

  final String text;
  final Icon? icon;
  final bool iconOnly;
  final double minHeight;
  final List<DropDownButtonAction> actions;

  DropDownButton({
    Key? key,
    required this.text,
    this.icon,
    this.iconOnly = false,
    this.minHeight = 40,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final textStyle = defaultTextStyle();

    if (iconOnly) {
      int i = -1;
      final menuItems = actions.map(
        (e) {
          i = i + 1;
          return PopupMenuItem<int>(
            padding: EdgeInsets.zero,
            child: OnHover(
              builder: (isHovered) {
                return ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          e.text,
                          style: textStyle,
                        ),
                      ),
                      SizedBox(
                          width: 25,
                          child: e.checked
                              ? Checkbox(
                                  value: true,
                                  onChanged: (_) {},
                                )
                              : null),
                    ],
                  ),
                  tileColor: isHovered ? themeData.hoverColor : Colors.transparent,
                );
              },
            ),
            value: i,
          );
        },
      ).toList();

      return Theme(
        data: Theme.of(context).copyWith(
          tooltipTheme: TooltipThemeData(
            textStyle: textStyle,
            decoration: BoxDecoration(
              color: themeData.secondaryHeaderColor,
            ),
          ),
          hoverColor: Colors.transparent,
        ),
        child: InkResponse(
          onTap: () {},
          radius: 16,
          hoverColor: themeData.hoverColor,
          child: PopupMenuButton<int>(
            icon: Icon(
              icon!.icon!,
              color: themeData.primaryColor,
            ),
            onSelected: _action,
            itemBuilder: (_) => menuItems,
            tooltip: text,
          ),
        ),
      );
    }

    else {
      final prefixIcon = (icon != null)
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Icon(
                icon!.icon,
                size: icon!.size ?? defaultIconSize,
                color: themeData.primaryColor,
              ),
            )
          : null;

      final Size size = (TextPainter(
              text: TextSpan(text: text, style: textStyle),
              maxLines: 1,
              textScaleFactor: MediaQuery.of(context).textScaleFactor,
              textDirection: TextDirection.ltr)
            ..layout())
          .size;

      int i = -1;
      final menuItems = actions.map(
        (e) {
          i = i + 1;
          return DropdownMenuItem<int>(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    e.text,
                    style: textStyle,
                  ),
                ),
                e.checked
                    ? const Icon(
                  Icons.check,
                  size: 16,
                )
                    : const SizedBox.shrink(),
              ],
            ),
            value: i,
          );
        },
      ).toList();

      final dropDownIcon = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 4.0,
              bottom: 4.0,
              right: 2.0,
            ),
            child: VerticalDivider(
              width: 1,
              color: themeData.textTheme.caption?.color,
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down,
            color: themeData.textTheme.caption?.color,
          ),
        ],
      );

      final widget = SizedBox(
        width: 50 + (icon != null ? 40: 0) + size.width,
        child: InputDecorator(
          decoration: InputDecoration(
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 2),
            constraints: const BoxConstraints(maxHeight: BaseWidget.iconMaxHeight + 6, maxWidth: 50),
            prefixIcon: prefixIcon,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              icon: dropDownIcon,
              isDense: true,
              isExpanded: true,
              focusColor: Colors.transparent,
              hint: Text(
                text,
                style: defaultTextStyle(color: themeData.textTheme.labelMedium?.color),
              ),
              items: menuItems,
              onChanged: _action,
            ),
          ),
        ),
      );

      // To make focus color of DropdownMenuItem transparent
      return Theme(
        data: Theme.of(context).copyWith(
          focusColor: Colors.transparent,
        ),
        child: widget
      );
    }

  }

  _action (int? idx) {
    if (idx != null) {
      final callBack = actions[idx].action;
      callBack();
    }
  }
}