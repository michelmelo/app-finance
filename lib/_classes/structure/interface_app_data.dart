// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'package:app_finance/_classes/storage/app_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_currency_picker/flutter_currency_picker.dart';

abstract interface class InterfaceAppData {
  String? uuid;
  Currency? currency;
  IconData? icon;
  MaterialColor? color;

  String get title;

  DateTime get createdAt;

  dynamic get details;

  AppDataType getType();

  String getClassName();

  void deactivate();
}
