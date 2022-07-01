import 'package:flutter/material.dart';

class OnHover extends StatefulWidget {
  final Widget Function(bool isHovered) builder;

  const OnHover({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  _OnHoverState createState() => _OnHoverState();
}

class _OnHoverState extends State<OnHover> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    // when user enter the mouse pointer onEnter method will work
    // when user exit the mouse pointer from MouseRegion onExit method will work
    return MouseRegion(
      onEnter: (_) => onEntered(true),
      onExit: (_) => onEntered(false),
      child: widget.builder(isHovered),
    );
  }

  //used to set bool isHovered to true/false
  void onEntered(bool isHovered) {
    if (isHovered != this.isHovered) {
      setState(() {
        this.isHovered = isHovered;
      });
    }
  }
}
