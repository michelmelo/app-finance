// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'package:app_finance/_classes/controller/focus_controller.dart';
import 'package:flutter/material.dart';

abstract class AbstractInput extends StatelessWidget {
  late final FocusNode focus;
  late final int focusOrder;
  late final bool isFocused;
  final dynamic value;

  AbstractInput({this.value, super.key}) {
    focus = FocusController.getFocusNode(value);
    focusOrder = FocusController.current;
    isFocused = FocusController.isFocused(focusOrder, value);
  }

  @override
  Widget build(BuildContext context) {
    FocusController.recordPosition(context, focusOrder);
    return buildContent(context);
  }

  Widget buildContent(BuildContext context);
}
