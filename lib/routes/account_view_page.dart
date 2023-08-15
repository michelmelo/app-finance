// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be
// found in the LICENSE file.

import 'package:adaptive_breakpoints/adaptive_breakpoints.dart';
import 'package:app_finance/_classes/data/account_app_data.dart';
import 'package:app_finance/_classes/app_menu.dart';
import 'package:app_finance/_classes/app_data.dart';
import 'package:app_finance/helpers/theme_helper.dart';
import 'package:app_finance/_classes/app_route.dart';
import 'package:app_finance/routes/abstract_page.dart';
import 'package:app_finance/widgets/home/base_line_widget.dart';
import 'package:app_finance/widgets/home/base_list_infinite_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class AccountViewPage extends AbstractPage {
  final String uuid;

  AccountViewPage({
    required this.uuid,
  }) : super();

  @override
  AccountViewPageState createState() => AccountViewPageState();
}

class AccountViewPageState extends AbstractPageState<AccountViewPage> {
  @override
  String getTitle(context) {
    final item = super.state.getByUuid(widget.uuid) as AccountAppData;
    return item.title;
  }

  void deactivateAccount(BuildContext context) {
    var data = super.state.getByUuid(widget.uuid) as AccountAppData;
    data.hidden = true;
    super.state.update(AppDataType.accounts, widget.uuid, data);
    Navigator.pop(context);
  }

  @override
  Widget buildButton(BuildContext context, BoxConstraints constraints) {
    String route = AppMenu(context: context).uuid(AppRoute.accountEditRoute, widget.uuid);
    double indent = ThemeHelper(windowType: getWindowType(context)).getIndent() * 4;
    return Container(
      margin: EdgeInsets.only(left: indent),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        FloatingActionButton(
          onPressed: () => deactivateAccount(context),
          tooltip: AppLocalizations.of(context)!.deleteAccountTooltip,
          child: const Icon(Icons.delete),
        ),
        FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, route),
          tooltip: AppLocalizations.of(context)!.editAccountTooltip,
          child: const Icon(Icons.edit),
        ),
      ]),
    );
  }

  Widget buildListWidget(item, BuildContext context, double offset) {
    item.setContext(context);
    return BaseLineWidget(
      uuid: '',
      title: '',
      description: item.getDateFormatted(item.timestamp),
      progress: 1.0,
      details: item.getNumberFormatted(item.changedTo - item.changedFrom),
      color: Colors.transparent,
      offset: offset,
    );
  }

  @override
  Widget buildContent(BuildContext context, BoxConstraints constraints) {
    final item = super.state.getByUuid(widget.uuid) as AccountAppData;
    item.setContext(context);
    double indent = ThemeHelper(windowType: getWindowType(context)).getIndent() * 2;
    double offset = MediaQuery.of(context).size.width - indent * 3;
    return Column(
      children: [
        BaseLineWidget(
          uuid: item.uuid ?? '',
          title: item.title,
          description: item.description ?? '',
          details: item.detailsFormatted,
          progress: item.progress,
          color: item.color ?? Colors.transparent,
          offset: offset,
          route: AppRoute.accountViewRoute,
        ),
        Expanded(
          child: BaseListInfiniteWidget(
            state: super.state.getLog(widget.uuid),
            offset: offset,
            buildListWidget: buildListWidget,
          ),
        ),
        const SizedBox(height: 70)
      ],
    );
  }
}
