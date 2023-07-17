// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:gherkin/gherkin.dart';

import '../file_runner.dart';

class TapDefinedHeader extends When1WithWorld<String, World> {
  @override
  RegExp get pattern => RegExp(r"I tap {string} header");

  @override
  Future<void> executeStep(String name) async {
    expect(find.text(name), findsOneWidget);
    await FileRunner.tester.tap(find.text(name));
    await FileRunner.tester.pumpAndSettle();
  }
}
