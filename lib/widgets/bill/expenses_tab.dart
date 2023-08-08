// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be
// found in the LICENSE file.

import 'package:adaptive_breakpoints/adaptive_breakpoints.dart';
import 'package:app_finance/_classes/app_route.dart';
import 'package:app_finance/_classes/data/bill_app_data.dart';
import 'package:app_finance/_classes/focus_controller.dart';
import 'package:app_finance/_mixins/shared_preferences_mixin.dart';
import 'package:app_finance/custom_text_theme.dart';
import 'package:app_finance/_classes/app_data.dart';
import 'package:app_finance/helpers/theme_helper.dart';
import 'package:app_finance/widgets/_forms/currency_exchange_input.dart';
import 'package:app_finance/widgets/_forms/currency_selector.dart';
import 'package:app_finance/widgets/_forms/date_time_input.dart';
import 'package:app_finance/widgets/_forms/list_account_selector.dart';
import 'package:app_finance/widgets/_forms/list_budget_selector.dart';
import 'package:app_finance/widgets/_forms/simple_input.dart';
import 'package:app_finance/widgets/_wrappers/required_widget.dart';
import 'package:app_finance/widgets/_wrappers/row_widget.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:provider/provider.dart';

class ExpensesTab<T> extends StatefulWidget {
  final String? account;
  final String? budget;
  final Currency? currency;
  final double? bill;
  final String? description;
  final DateTime? createdAt;

  const ExpensesTab({
    super.key,
    this.account,
    this.budget,
    this.currency,
    this.bill,
    this.description,
    this.createdAt,
  });

  @override
  ExpensesTabState createState() => ExpensesTabState();
}

class ExpensesTabState<T extends ExpensesTab> extends State<T> with SharedPreferencesMixin {
  late AppData state;
  String? account;
  String? budget;
  Currency? currency;
  late TextEditingController bill;
  late TextEditingController description;
  double? billValue;
  DateTime? createdAt;
  bool hasErrors = false;
  bool isFresh = true;

  @override
  void initState() {
    account = widget.account;
    budget = widget.budget;
    currency = widget.currency;
    bill = TextEditingController(text: widget.bill != null ? widget.bill.toString() : '');
    billValue = widget.bill;
    description = TextEditingController(text: widget.description);
    createdAt = widget.createdAt;
    super.initState();
  }

  Future<void> _loadPreferences() async {
    await Future.delayed(Duration.zero);
    setState(() {
      isFresh = false;

      final accountId = getPreference(prefAccount);
      final objAccount = state.getByUuid(accountId ?? '');
      account ??= objAccount?.uuid;
      currency ??= objAccount?.currency;

      final budgetId = getPreference(prefBudget);
      final objBudget = state.getByUuid(budgetId ?? '');
      budget ??= objBudget?.uuid;
      currency ??= objBudget?.currency;

      final currencyId = getPreference(prefCurrency);
      currency ??= CurrencyService().findByCode(currencyId);
    });
  }

  bool hasFormErrors() {
    setState(() => hasErrors = account == null || budget == null || bill.text.isEmpty);
    return hasErrors;
  }

  void updateStorage() {
    setPreference(prefAccount, account ?? '');
    setPreference(prefBudget, budget ?? '');
    state.add(
        AppDataType.bills,
        BillAppData(
          account: account ?? '',
          category: budget ?? '',
          currency: currency,
          title: description.text,
          details: double.tryParse(bill.text) ?? 0.0,
          createdAt: createdAt ?? DateTime.now(),
        ));
  }

  String getButtonTitle(context) {
    return AppLocalizations.of(context)!.createBillTooltip;
  }

  Widget buildButton(BuildContext context, BoxConstraints constraints) {
    var helper = ThemeHelper(windowType: getWindowType(context));
    String title = getButtonTitle(context);
    return SizedBox(
      width: constraints.maxWidth - helper.getIndent() * 4,
      child: FloatingActionButton(
        onPressed: () => {
          setState(() {
            if (hasFormErrors()) {
              return;
            }
            updateStorage();
            Navigator.popAndPushNamed(context, AppRoute.homeRoute);
          })
        },
        focusNode: FocusController.getFocusNode(),
        tooltip: title,
        child: Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.save),
              SizedBox(height: helper.getIndent()),
              Text(title, style: Theme.of(context).textTheme.headlineMedium)
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // FocusController.dispose();
    final TextTheme textTheme = Theme.of(context).textTheme;
    double indent = ThemeHelper(windowType: getWindowType(context)).getIndent() * 2;
    double offset = MediaQuery.of(context).size.width - indent * 3;
    FocusController.init();

    return LayoutBuilder(builder: (context, constraints) {
      return Consumer<AppData>(builder: (context, appState, _) {
        state = appState;
        if (isFresh) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _loadPreferences());
        }
        return Scaffold(
          body: SingleChildScrollView(
            controller: FocusController.getController(),
            child: Container(
              margin: EdgeInsets.fromLTRB(indent, indent, indent, 240),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RequiredWidget(
                    title: AppLocalizations.of(context)!.account,
                    showError: hasErrors && account == null,
                  ),
                  ListAccountSelector(
                    value: account,
                    state: state,
                    setState: (value) => setState(() {
                      account = value;
                      currency ??= state.getByUuid(value).currency;
                    }),
                    style: textTheme.numberMedium.copyWith(color: textTheme.headlineSmall?.color),
                    indent: indent,
                    width: offset,
                  ),
                  SizedBox(height: indent),
                  RequiredWidget(
                    title: AppLocalizations.of(context)!.budget,
                    showError: hasErrors && budget == null,
                  ),
                  ListBudgetSelector(
                    value: budget,
                    state: state,
                    setState: (value) => setState(() {
                      budget = value;
                      var bdgCurrency = state.getByUuid(value).currency;
                      currency ??= bdgCurrency;
                    }),
                    style: textTheme.numberMedium.copyWith(color: textTheme.headlineSmall?.color),
                    indent: indent,
                    width: offset,
                  ),
                  SizedBox(height: indent),
                  RowWidget(
                    indent: indent,
                    maxWidth: offset,
                    chunk: const [0.32, 0.68],
                    children: [
                      [
                        Text(
                          AppLocalizations.of(context)!.currency,
                          style: textTheme.bodyLarge,
                        ),
                        Container(
                          color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.3),
                          width: double.infinity,
                          child: CurrencySelector(
                            value: currency?.code,
                            setView: (Currency currency) => currency.code,
                            setState: (value) => setState(() => currency = value),
                          ),
                        ),
                      ],
                      [
                        RequiredWidget(
                          title: AppLocalizations.of(context)!.expense,
                          showError: hasErrors && bill.text.isEmpty,
                        ),
                        SimpleInput(
                          controller: bill,
                          type: const TextInputType.numberWithOptions(decimal: true),
                          tooltip: AppLocalizations.of(context)!.billSetTooltip,
                          style: textTheme.numberMedium.copyWith(color: textTheme.headlineSmall?.color),
                          setState: (v) => setState(() => billValue = double.tryParse(v)),
                          formatter: [
                            SimpleInput.filterDouble,
                          ],
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: indent),
                  CurrencyExchangeInput(
                    width: offset + indent,
                    indent: indent,
                    target: currency,
                    state: state,
                    targetAmount: billValue,
                    source: [
                      account != null ? state.getByUuid(account!).currency : null,
                      budget != null ? state.getByUuid(budget!).currency : null,
                    ].cast<Currency?>(),
                  ),
                  Text(
                    AppLocalizations.of(context)!.description,
                    style: textTheme.bodyLarge,
                  ),
                  SimpleInput(
                    controller: description,
                    tooltip: AppLocalizations.of(context)!.descriptionTooltip,
                    style: textTheme.numberMedium.copyWith(color: textTheme.headlineSmall?.color),
                  ),
                  SizedBox(height: indent),
                  Text(
                    AppLocalizations.of(context)!.expenseDateTime,
                    style: textTheme.bodyLarge,
                  ),
                  DateTimeInput(
                    style: textTheme.numberMedium.copyWith(color: textTheme.headlineSmall?.color),
                    width: offset,
                    value: createdAt ?? DateTime.now(),
                    setState: (value) => setState(() => createdAt = value),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: buildButton(context, constraints),
        );
      });
    });
  }
}