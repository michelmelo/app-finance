// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class ToolbarButtonWidget extends StatefulWidget {
  final Widget child;
  final Color? borderColor;
  final double offset;

  const ToolbarButtonWidget({
    super.key,
    required this.child,
    this.borderColor,
    this.offset = -4,
  });

  @override
  ToolbarButtonWidgetState createState() => ToolbarButtonWidgetState();
}

class ToolbarButtonWidgetState extends State<ToolbarButtonWidget> {
  Color color = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => color = Colors.black26),
      onExit: (_) => setState(() => color = Colors.transparent),
      child: Container(
        margin: const EdgeInsets.all(4.0),
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: color,
          border: Border.all(color: widget.borderColor ?? Colors.white30, width: 1),
        ),
        child: Transform.translate(
          offset: Offset(0, widget.offset),
          child: Material(
            elevation: 0,
            color: Colors.transparent,
            borderRadius: BorderRadius.zero,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}