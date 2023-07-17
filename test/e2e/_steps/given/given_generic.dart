// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be
// found in the LICENSE file.

import 'package:app_finance/_classes/gen/generate_gherkin_resources.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:gherkin/gherkin.dart';

import '../file_reader.dart';
import '../file_runner.dart';

@GenerateGherkinResources(['../../'])
class GivenGeneric extends Given {
  @override
  RegExp get pattern => RegExp('%step%');

  @override
  Future<void> executeStep() async {
    final step = await FileReader().getFromString('''
    %feature%
    ''');
    expect(await FileRunner(FileRunner.tester).run(step), true);
  }
}
