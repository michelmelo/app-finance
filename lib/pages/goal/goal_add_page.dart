// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'package:app_finance/_classes/herald/app_locale.dart';
import 'package:app_finance/_classes/structure/currency/exchange.dart';
import 'package:app_finance/_classes/structure/goal_app_data.dart';
import 'package:app_finance/_classes/controller/focus_controller.dart';
import 'package:app_finance/_classes/storage/app_data.dart';
import 'package:app_finance/_configs/theme_helper.dart';
import 'package:app_finance/_classes/storage/app_preferences.dart';
import 'package:app_finance/_ext/build_context_ext.dart';
import 'package:app_finance/pages/abstract_page_state.dart';
import 'package:app_finance/widgets/form/color_selector.dart';
import 'package:app_finance/widgets/form/currency_selector.dart';
import 'package:app_finance/widgets/form/date_input.dart';
import 'package:app_finance/widgets/wrapper/full_sized_button_widget.dart';
import 'package:app_finance/widgets/form/icon_selector.dart';
import 'package:app_finance/widgets/form/simple_input.dart';
import 'package:app_finance/widgets/wrapper/required_widget.dart';
import 'package:app_finance/widgets/wrapper/row_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_currency_picker/flutter_currency_picker.dart';

class GoalAddPage extends StatefulWidget {
  final String? title;
  final IconData? icon;
  final MaterialColor? color;
  final Currency? currency;
  final double? details;
  final DateTime? closedAt;

  const GoalAddPage({
    super.key,
    this.title,
    this.icon,
    this.color,
    this.currency,
    this.details,
    this.closedAt,
  });

  @override
  GoalAddPageState createState() => GoalAddPageState();
}

class GoalAddPageState<T extends GoalAddPage> extends AbstractPageState<GoalAddPage> {
  late TextEditingController title;
  IconData? icon;
  MaterialColor? color;
  Currency? currency;
  late TextEditingController details;
  DateTime? closedAt;
  bool hasError = false;

  @override
  void initState() {
    title = TextEditingController(text: widget.title);
    icon = widget.icon;
    color = widget.color;
    details = TextEditingController(text: widget.details != null ? widget.details.toString() : '');
    final currencyId = AppPreferences.get(AppPreferences.prefCurrency);
    currency = widget.currency ?? CurrencyProvider.find(currencyId);
    closedAt = widget.closedAt;
    super.initState();
  }

  @override
  String getTitle() {
    return AppLocale.labels.createGoalHeader;
  }

  bool hasFormErrors() {
    setState(() => hasError = title.text.isEmpty || closedAt == null);
    return hasError;
  }

  void updateStorage() {
    super.state.add(GoalAppData(
          title: title.text,
          initial: Exchange(store: super.state)
              .reform(super.state.getTotal(AppDataType.accounts), Exchange.defaultCurrency, currency),
          progress: 0.0,
          color: color,
          hidden: false,
          currency: currency,
          icon: icon,
          details: double.tryParse(details.text) ?? 0.0,
          closedAt: closedAt,
        ));
  }

  @override
  String getButtonName() => AppLocale.labels.createGoalTooltip;

  @override
  Widget buildButton(BuildContext context, BoxConstraints constraints) {
    NavigatorState nav = Navigator.of(context);
    return FullSizedButtonWidget(
      constraints: constraints,
      setState: () => {
        setState(() {
          if (hasFormErrors()) {
            return;
          }
          updateStorage();
          nav.pop();
          nav.pop();
        })
      },
      title: getButtonName(),
      icon: Icons.save,
    );
  }

  @override
  Widget buildContent(BuildContext context, BoxConstraints constraints) {
    final TextTheme textTheme = context.textTheme;
    double indent = ThemeHelper.getIndent(2);
    double width = ThemeHelper.getWidth(context, 6);

    return SingleChildScrollView(
      controller: FocusController.getController(runtimeType),
      child: Container(
        margin: EdgeInsets.fromLTRB(indent, indent, indent, 240),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RequiredWidget(title: AppLocale.labels.titleGoal, showError: hasError && title.text.isEmpty),
            SimpleInput(
              controller: title,
              tooltip: AppLocale.labels.titleGoalTooltip,
            ),
            ThemeHelper.hIndent2x,
            RowWidget(
              indent: indent,
              maxWidth: width + indent,
              alignment: MainAxisAlignment.start,
              chunk: const [null, null],
              children: [
                [
                  Text(
                    AppLocale.labels.icon,
                    style: textTheme.bodyLarge,
                  ),
                  IconSelector(
                    value: icon,
                    setState: (value) => setState(() => icon = value),
                  ),
                ],
                [
                  Text(
                    AppLocale.labels.color,
                    style: textTheme.bodyLarge,
                  ),
                  ColorSelector(
                    value: color,
                    setState: (value) => setState(() => color = value),
                  ),
                ],
              ],
            ),
            ThemeHelper.hIndent2x,
            RowWidget(
              indent: indent,
              maxWidth: width + indent,
              alignment: MainAxisAlignment.start,
              chunk: const [120, null],
              children: [
                [
                  Text(
                    AppLocale.labels.currency,
                    style: textTheme.bodyLarge,
                  ),
                  CodeCurrencySelector(
                    value: currency?.code,
                    textTheme: context.textTheme,
                    colorScheme: context.colorScheme,
                    update: (value) => setState(() => currency = value),
                  ),
                ],
                [
                  Text(
                    AppLocale.labels.targetAmount,
                    style: textTheme.bodyLarge,
                  ),
                  SimpleInput(
                    controller: details,
                    type: const TextInputType.numberWithOptions(decimal: true),
                    tooltip: AppLocale.labels.billSetTooltip,
                    formatter: [
                      SimpleInputFormatter.filterDouble,
                    ],
                  ),
                ],
              ],
            ),
            ThemeHelper.hIndent2x,
            RequiredWidget(title: AppLocale.labels.closedAt, showError: hasError && closedAt == null),
            DateInput(
              value: closedAt,
              setState: (value) => setState(() => closedAt = value),
            ),
          ],
        ),
      ),
    );
  }
}
