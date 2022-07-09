import 'dart:async';

import 'package:flutter/material.dart';

class ToastMessagePane extends StatefulWidget {
  final double width;
  late final _ToastMessage toast;

  ToastMessagePane({
    Key? key,
    required this.width,
    required String message,
    required Color color,
    required Color textColor,
    required Icon icon,
    required VoidCallback closeAction,
    required DateTime closeTime,
  }) : super(key: key) {
    toast = _ToastMessage(
      key: UniqueKey(),
      width: width,
      backgroundColor: color,
      textColor: textColor,
      icon: icon,
      message: message,
      closeTime: closeTime,
      closeAction: closeAction,
    );
  }

  @override
  State<ToastMessagePane> createState() => ToastMessagePaneState();
}

class ToastMessagePaneState extends State<ToastMessagePane> {
  final List<_ToastMessage> messages = [];

  @override
  void initState() {
    super.initState();
    final t = widget.toast;
    addToastMessage(
      message: t.message,
      color: t.backgroundColor,
      textColor: t.textColor,
      icon: t.icon,
      closeAction: t.closeAction,
      closeTime: t.closeTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 20.0,
      ),
      child: Column(
        children: messages,
      ),
    );
  }

  void addToastMessage({
    required String message,
    required Color color,
    required Color textColor,
    required Icon icon,
    required VoidCallback closeAction,
    required DateTime closeTime,
  }) {
    final key = UniqueKey();
    messages.add(
      _ToastMessage(
        key: key,
        width: widget.width,
        backgroundColor: color,
        textColor: textColor,
        icon: icon,
        message: message,
        closeTime: closeTime,
        closeAction: () {
          messages.removeWhere((element) => element.key == key);
          closeAction();
        },
      ),
    );
    setState(() {});
  }
}

class _ToastMessage extends StatefulWidget {
  final double width;
  final Color backgroundColor;
  final Icon icon;
  final String message;
  final Color textColor;
  final VoidCallback closeAction;
  final DateTime closeTime;
  late final int autoDismissMillis;

  _ToastMessage({
    Key? key,
    required this.width,
    required this.backgroundColor,
    required this.icon,
    required this.message,
    required this.textColor,
    required this.closeAction,
    required this.closeTime,
  }) : super(key: key) {
    final now = DateTime.now();
    autoDismissMillis = closeTime.millisecondsSinceEpoch - now.millisecondsSinceEpoch;
  }

  @override
  State<_ToastMessage> createState() => _ToastMessageState();
}

class _ToastMessageState extends State<_ToastMessage> {
  static const double height = 65;
  late bool visible;

  @override
  void initState() {
    super.initState();
    visible = true;

    if (widget.autoDismissMillis > 0) {
      Timer(Duration(milliseconds: widget.autoDismissMillis), () {
        visible = false;
        setState(() {
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: visible ? height : 0,
      duration: const Duration(milliseconds: 250),
      onEnd: widget.closeAction,
      child: Row(
        children: [
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Container(
              width: widget.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: widget.backgroundColor,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2.0,
                    spreadRadius: 0.0,
                    offset: Offset(2.0, 2.0), // shadow direction: bottom right
                  )
                ],
              ),
              child: Material(
                color: widget.backgroundColor,
                child: visible
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18.0),
                            child: widget.icon,
                          ),
                          Text(
                            widget.message,
                            style: TextStyle(
                              color: widget.textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18.0),
                              alignment: Alignment.centerRight,
                              child: widget.autoDismissMillis <= 0
                                  ? InkWell(
                                      onTap: () {
                                        visible = false;
                                        setState(() {
                                          widget.closeAction();
                                        });
                                      },
                                      child: Icon(
                                        Icons.close,
                                        color: widget.textColor,
                                        size: 16,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          )
                        ],
                      )
                    : const SizedBox(height: height),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
