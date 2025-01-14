// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

class ToolbarButtonWidget extends StatefulWidget {
  final Widget child;
  final Color? borderColor;
  final Color? backgroundColor;
  final Offset? offset;
  final EdgeInsets margin;

  const ToolbarButtonWidget({
    super.key,
    required this.child,
    this.borderColor,
    this.backgroundColor,
    this.offset,
    this.margin = const EdgeInsets.all(4.0),
  });

  @override
  ToolbarButtonWidgetState createState() => ToolbarButtonWidgetState();
}

class ToolbarButtonWidgetState extends State<ToolbarButtonWidget> {
  late Color color = widget.backgroundColor ?? Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => color = Colors.black26),
      onExit: (_) => setState(() => color = widget.backgroundColor ?? Colors.transparent),
      child: Container(
        margin: widget.margin,
        padding: EdgeInsets.zero,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: color,
          border: Border.all(color: widget.borderColor ?? Colors.white30, width: 1),
        ),
        child: LayoutBuilder(builder: (context, constraints) {
          return Transform.translate(
            offset: widget.offset ?? Offset(constraints.maxWidth > 30 ? 0 : -4, -4),
            child: Material(
              elevation: 0,
              color: Colors.transparent,
              borderRadius: BorderRadius.zero,
              child: widget.child,
            ),
          );
        }),
      ),
    );
  }
}
