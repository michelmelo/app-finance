// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be
// found in the LICENSE file.

import 'package:adaptive_breakpoints/adaptive_breakpoints.dart';
import 'package:app_finance/_classes/app_route.dart';
import 'package:app_finance/_classes/data/account_app_data.dart';
import 'package:app_finance/_classes/focus_controller.dart';
import 'package:app_finance/custom_text_theme.dart';
import 'package:app_finance/data.dart';
import 'package:app_finance/helpers/theme_helper.dart';
import 'package:app_finance/widgets/forms/currency_selector.dart';
import 'package:app_finance/widgets/forms/list_account_selector.dart';
import 'package:app_finance/widgets/forms/simple_input.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:provider/provider.dart';

class TransferTab extends StatefulWidget {
  String? accountFrom;
  String? accountTo;
  double? amount;
  Currency? currency;

  TransferTab({
    super.key,
    this.accountFrom,
    this.accountTo,
    this.amount,
    this.currency,
  });

  @override
  TransferTabState createState() => TransferTabState();
}

class TransferTabState extends State<TransferTab> {
  late AppData state;
  String? accountFrom;
  String? accountTo;
  double? amount;
  Currency? currency;
  String accountErrorMessage = '';

  @override
  void initState() {
    accountFrom = widget.accountFrom;
    accountTo = widget.accountTo;
    amount = widget.amount;
    currency = widget.currency;
    super.initState();
  }

  bool hasFormErrors() {
    bool isError = false;
    if (accountFrom == null || accountTo == null) {
      accountErrorMessage = AppLocalizations.of(context)!.isRequired;
      isError = true;
    }
    return isError;
  }

  void updateStorage() {
    String uuidFrom = accountFrom ?? '';
    AccountAppData from = state.getByUuid(uuidFrom);
    from.details -= amount ?? 0.0;
    state.update(AppDataType.accounts, uuidFrom, from);
    String uuidTo = accountTo ?? '';
    AccountAppData to = state.getByUuid(uuidTo);
    to.details += amount ?? 0.0;
    state.update(AppDataType.accounts, uuidTo, to);
  }

  Widget buildButton(BuildContext context, BoxConstraints constraints) {
    var helper = ThemeHelper(windowType: getWindowType(context));
    String title = AppLocalizations.of(context)!.createTransferTooltip;
    FocusController.setContext(3);
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
    double indent =
        ThemeHelper(windowType: getWindowType(context)).getIndent() * 2;
    double offset = MediaQuery.of(context).size.width - indent * 3;
    int focusOrder = FocusController.DEFAULT;

    return LayoutBuilder(builder: (context, constraints) {
      return Consumer<AppData>(builder: (context, appState, _) {
        state = appState;
        return Scaffold(
          body: SingleChildScrollView(
            controller: FocusController.getController(),
            child: Container(
              margin: EdgeInsets.fromLTRB(indent, indent, indent, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${AppLocalizations.of(context)!.accountFrom}*',
                        style: textTheme.bodyLarge,
                      ),
                      Text(
                        accountErrorMessage,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                  ListAccountSelector(
                    value: accountFrom,
                    state: state,
                    setState: (value) => setState(() {
                      accountFrom = value;
                    }),
                    style: textTheme.numberMedium,
                    indent: indent,
                    width: offset,
                    focusOrder: focusOrder += 1,
                  ),
                  SizedBox(height: indent),
                  Row(
                    children: [
                      Text(
                        '${AppLocalizations.of(context)!.accountTo}*',
                        style: textTheme.bodyLarge,
                      ),
                      Text(
                        accountErrorMessage,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                  ListAccountSelector(
                    value: accountTo,
                    state: state,
                    setState: (value) => setState(() {
                      accountTo = value;
                    }),
                    style: textTheme.numberMedium,
                    indent: indent,
                    width: offset,
                    focusOrder: focusOrder += 1,
                  ),
                  SizedBox(height: indent),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: offset * 0.3,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.currency,
                              style: textTheme.bodyLarge,
                            ),
                            Container(
                              color: Theme.of(context)
                                  .colorScheme
                                  .inversePrimary
                                  .withOpacity(0.3),
                              width: double.infinity,
                              child: CurrencySelector(
                                value: currency,
                                setView: (Currency currency) => currency.code,
                                setState: (value) =>
                                    setState(() => currency = value),
                                focusOrder: focusOrder += 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: indent),
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: offset * 0.7,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.expenseTransfer,
                              style: textTheme.bodyLarge,
                            ),
                            SimpleInput(
                              value: amount != null ? amount.toString() : '',
                              type: const TextInputType.numberWithOptions(
                                  decimal: true),
                              tooltip:
                                  AppLocalizations.of(context)!.billSetTooltip,
                              style: textTheme.numberMedium,
                              formatter: [
                                SimpleInput.filterDouble,
                              ],
                              setState: (value) => setState(
                                  () => amount = double.tryParse(value)),
                              focusOrder: focusOrder += 1,
                            ),
                          ],
                        ),
                      ),
                    ],
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
