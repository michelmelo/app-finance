// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

class ChartData {
  final List<Offset> data;
  final MaterialColor color;
  final dynamic helper;

  ChartData(this.data, {this.color = Colors.red, this.helper});
}
