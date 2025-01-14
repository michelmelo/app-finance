// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'package:app_finance/_classes/herald/app_locale.dart';
import 'package:app_finance/_configs/theme_helper.dart';
import 'package:app_finance/pages/abstract_page_state.dart';
import 'package:app_finance/widgets/generic/loading_widget.dart';
import 'package:flutter/material.dart';

class InitTab extends StatefulWidget {
  const InitTab({super.key});

  @override
  InitTabState createState() => InitTabState();
}

class InitTabState extends AbstractPageState<InitTab> {
  @override
  Drawer? buildDrawer() {
    return null;
  }

  @override
  List<Widget> getBarActions(NavigatorState nav) => [];

  @override
  Widget? getBarLeading(NavigatorState nav) => null;

  @override
  String getButtonName() => '';

  @override
  Widget buildButton(BuildContext context, BoxConstraints constraints) {
    return ThemeHelper.emptyBox;
  }

  @override
  Widget buildContent(BuildContext context, BoxConstraints constraints) {
    return LoadingWidget(isLoading: super.state.isLoading);
  }

  @override
  String getTitle() {
    return AppLocale.labels.appInitHeadline;
  }
}
