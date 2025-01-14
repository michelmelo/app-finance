// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'package:app_finance/_classes/storage/app_data.dart';
import 'package:app_finance/_classes/herald/app_locale.dart';
import 'package:app_finance/_classes/storage/file_parser.dart';
import 'package:app_finance/_classes/storage/file_picker.dart';
import 'package:app_finance/_classes/storage/transaction_log.dart';
import 'package:app_finance/_classes/controller/focus_controller.dart';
import 'package:app_finance/_classes/structure/def/list_selector_item.dart';
import 'package:app_finance/_classes/structure/interface_app_data.dart';
import 'package:app_finance/_configs/date_format_helper.dart';
import 'package:app_finance/_classes/storage/app_preferences.dart';
import 'package:app_finance/_configs/theme_helper.dart';
import 'package:app_finance/_ext/build_context_ext.dart';
import 'package:app_finance/widgets/form/currency_selector.dart';
import 'package:app_finance/widgets/form/list_account_selector.dart';
import 'package:app_finance/widgets/form/list_budget_selector.dart';
import 'package:app_finance/widgets/form/list_selector.dart';
import 'package:app_finance/widgets/form/simple_input.dart';
import 'package:app_finance/widgets/generic/loading_widget.dart';
import 'package:app_finance/pages/settings/widgets/recover_tab/date_time_helper_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ImportTab extends StatefulWidget {
  const ImportTab({
    super.key,
  });

  @override
  ImportTabState createState() => ImportTabState();
}

class ImportTabState extends State<ImportTab> {
  late AppData state;
  List<List<dynamic>>? fileContent;
  StringBuffer errorMessage = StringBuffer();
  List<String> columnMap = [];
  bool isLoading = false;
  final dateFormat = TextEditingController(text: 'M/d/yyyy HH:mm');

  late Map<String, String?> attrValue = {
    FileParser.attrAccountName: AppPreferences.get(AppPreferences.prefAccount),
    FileParser.attrCategoryName: AppPreferences.get(AppPreferences.prefBudget),
    FileParser.attrBillCurrency: AppPreferences.get(AppPreferences.prefCurrency),
    FileParser.attrBillType: AppLocale.labels.bill,
  };

  Future<void> pickFile(List<String> ext) async {
    try {
      setState(() => errorMessage.clear());
      final picker = FilePicker(ext);
      final content = await picker.pickFile();
      setState(() {
        fileContent = content;
        columnMap = picker.columnMap;
        if (columnMap.contains(FileParser.attrBillDate)) {
          int index = columnMap.indexOf(FileParser.attrBillDate);
          dateFormat.text = DateFormatHelper().detectFormat([fileContent!.last[index]], AppLocale.code);
        }
      });
    } catch (e) {
      setState(() => errorMessage.writeln(e.toString()));
      rethrow;
    }
  }

  Future<void> parseFile() async {
    state.isLoading = true;
    fnSearch(AppDataType type, String value) => state.getList(type).where((e) => e.title == value).firstOrNull;
    fnAdd(InterfaceAppData item) {
      item = state.add(item);
      TransactionLog.save(item);
      return item;
    }

    final parser = FileParser(columnMap: columnMap, search: fnSearch, add: fnAdd);
    final def = {
      FileParser.attrAccountName: attrValue[FileParser.attrAccountName],
      FileParser.attrCategoryName: attrValue[FileParser.attrCategoryName],
      FileParser.attrBillCurrency: attrValue[FileParser.attrBillCurrency],
      FileParser.defDateFormat: dateFormat.text,
    };
    for (int i = 1; i < (fileContent?.length ?? 0); i++) {
      try {
        dynamic newItem = await parser.parseFileLine(fileContent![i], def);
        newItem = state.add(newItem, newItem.uuid);
        TransactionLog.save(newItem);
      } catch (e) {
        setState(() => errorMessage.writeln('[$i / ${fileContent!.length}] ${e.toString()}.'));
      }
    }
    await state.restate();
    setState(() => fileContent = null);
  }

  Future<void> wrapCall(Function callback) async {
    setState(() {
      isLoading = true;
      errorMessage.clear();
    });
    await callback();
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      isLoading = false;
      String isFinished = AppLocale.labels.processIsFinished;
      errorMessage.write(isFinished);
      if (errorMessage.toString() == isFinished) {
        Future.delayed(const Duration(seconds: 2), () => setState(() => errorMessage.clear()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final indent = ThemeHelper.getIndent(2);
    final width = ThemeHelper.getWidth(context, 12);
    final textTheme = context.textTheme;
    final ColorScheme colorScheme = context.colorScheme;
    FocusController.init();

    return Consumer<AppData>(builder: (context, appState, _) {
      state = appState;
      return SingleChildScrollView(
        controller: FocusController.getController(runtimeType),
        child: Padding(
          padding: EdgeInsets.all(indent),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ThemeHelper.hIndent2x,
              if (errorMessage.toString() != '')
                Text(errorMessage.toString(), style: textTheme.bodyMedium?.copyWith(color: colorScheme.error)),
              if (isLoading) ...[
                SizedBox(height: indent * 6),
                LoadingWidget(isLoading: isLoading),
              ] else if (fileContent != null) ...[
                ...List<Widget>.generate(fileContent!.first.length, (index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ThemeHelper.hIndent2x,
                      Text(
                        AppLocale.labels.columnMap(fileContent!.first[index]),
                        style: textTheme.bodyLarge,
                      ),
                      ListSelector(
                        options: FileParser.getMappingTypes(),
                        value: columnMap[index],
                        hintText: AppLocale.labels.columnMapTooltip(fileContent!.first[index]),
                        setState: (value) => setState(() {
                          columnMap[index] = value;
                          if (value == FileParser.attrBillDate) {
                            dateFormat.text =
                                DateFormatHelper().detectFormat([fileContent!.last[index]], AppLocale.code);
                          }
                        }),
                      ),
                    ],
                  );
                }),
                const Divider(),
                if (!columnMap.contains(FileParser.attrAccountName)) ...[
                  ThemeHelper.hIndent2x,
                  Text(
                    AppLocale.labels.def('${AppLocale.labels.account}: ${AppLocale.labels.title}'),
                    style: textTheme.bodyLarge,
                  ),
                  ListAccountSelector(
                    state: state,
                    hintText: AppLocale.labels.titleAccountTooltip,
                    value: attrValue[FileParser.attrAccountName],
                    setState: (value) => setState(() => attrValue[FileParser.attrAccountName] = value),
                    width: width,
                  ),
                ],
                if (!columnMap.contains(FileParser.attrCategoryName)) ...[
                  ThemeHelper.hIndent2x,
                  Text(
                    AppLocale.labels.def('${AppLocale.labels.budget}: ${AppLocale.labels.title}'),
                    style: textTheme.bodyLarge,
                  ),
                  ListBudgetSelector(
                    state: state,
                    hintText: AppLocale.labels.titleBudgetTooltip,
                    value: attrValue[FileParser.attrCategoryName],
                    setState: (value) => setState(() => attrValue[FileParser.attrCategoryName] = value),
                    width: width,
                  ),
                ],
                if (!columnMap.contains(FileParser.attrBillType)) ...[
                  ThemeHelper.hIndent2x,
                  Text(
                    AppLocale.labels.def('${AppLocale.labels.bill}: ${AppLocale.labels.billTypeTooltip}'),
                    style: textTheme.bodyLarge,
                  ),
                  ListSelector(
                    value: attrValue[FileParser.attrBillType],
                    hintText: AppLocale.labels.billTypeTooltip,
                    options: [
                      ListSelectorItem(id: AppLocale.labels.bill, name: AppLocale.labels.bill),
                      ListSelectorItem(id: AppLocale.labels.flowTypeInvoice, name: AppLocale.labels.flowTypeInvoice),
                    ],
                    setState: (value) => setState(() => attrValue[FileParser.attrBillType] = value),
                  ),
                ],
                if (!columnMap.contains(FileParser.attrBillCurrency)) ...[
                  ThemeHelper.hIndent2x,
                  Text(
                    AppLocale.labels.def('${AppLocale.labels.bill}: ${AppLocale.labels.currency}'),
                    style: textTheme.bodyLarge,
                  ),
                  BaseCurrencySelector(
                    value: attrValue[FileParser.attrBillCurrency],
                    textTheme: context.textTheme,
                    colorScheme: context.colorScheme,
                    update: (value) => setState(() => attrValue[FileParser.attrBillCurrency] = value.code),
                  ),
                ],
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ThemeHelper.hIndent4x,
                  Text(
                    AppLocale.labels.dateFormat,
                    style: textTheme.bodyLarge,
                  ),
                  SimpleInput(controller: dateFormat),
                  const DateTimeHelperWidget(),
                  ThemeHelper.hIndent4x,
                  SizedBox(
                    width: double.infinity,
                    child: FloatingActionButton(
                      heroTag: 'import_tab_parse',
                      onPressed: () => wrapCall(parseFile),
                      tooltip: AppLocale.labels.parseFile,
                      child: Text(
                        AppLocale.labels.parseFile,
                      ),
                    ),
                  ),
                ]),
              ] else
                ...List<Widget>.generate(FilePicker.fileFormats.length * 2, (index) {
                  if (index % 2 == 0) {
                    return ThemeHelper.hIndent2x;
                  } else {
                    final format = FilePicker.fileFormats[index ~/ 2];
                    return SizedBox(
                      width: double.infinity,
                      child: FloatingActionButton(
                        heroTag: 'import_tab_pick_$format',
                        onPressed: () => wrapCall(() => pickFile([format])),
                        tooltip: AppLocale.labels.pickFile(format),
                        child: Text(
                          AppLocale.labels.pickFile(format),
                        ),
                      ),
                    );
                  }
                })
            ],
          ),
        ),
      );
    });
  }
}
