// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'package:app_finance/_classes/herald/app_locale.dart';
import 'package:app_finance/_classes/herald/app_palette.dart';
import 'package:app_finance/_classes/herald/app_theme.dart';
import 'package:app_finance/_classes/herald/app_zoom.dart';
import 'package:app_finance/_classes/storage/app_preferences.dart';
import 'package:app_finance/_classes/structure/def/list_selector_item.dart';
import 'package:app_finance/_configs/custom_color_scheme.dart';
import 'package:app_finance/_configs/theme_helper.dart';
import 'package:app_finance/_ext/build_context_ext.dart';
import 'package:app_finance/_ext/color_ext.dart';
import 'package:app_finance/widgets/form/color_selector.dart';
import 'package:app_finance/widgets/form/currency_selector.dart';
import 'package:app_finance/widgets/form/list_selector.dart';
import 'package:app_finance/pages/start/widgets/abstract_tab.dart';
import 'package:app_finance/widgets/wrapper/table_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_currency_picker/flutter_currency_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SettingTab extends AbstractTab {
  const SettingTab({
    super.key,
    required super.setState,
    super.isFirstBoot = true,
  });

  @override
  SettingTabState createState() => SettingTabState();
}

class SettingTabState<T extends SettingTab> extends AbstractTabState<T> {
  late AppTheme theme;
  late AppZoom zoom;
  late AppPalette palette;
  late AppLocale locale;
  Currency? currency;
  bool isEncrypted = false;
  bool hasEncrypted = false;
  String brightness = '0';
  String colorMode = AppPalette.state;
  var paletteState = (
    light: AppDefaultColors.fromString(AppPalette.light),
    dark: AppDefaultColors.fromString(AppPalette.dark),
  );

  @override
  void initState() {
    super.initState();
    final doEncrypt = AppPreferences.get(AppPreferences.prefDoEncrypt);
    hasEncrypted = doEncrypt != null;
    isEncrypted = doEncrypt == 'true' || doEncrypt == null;
    AppPreferences.set(AppPreferences.prefDoEncrypt, isEncrypted ? 'true' : 'false');
    brightness = AppPreferences.get(AppPreferences.prefTheme) ?? brightness;
    colorMode = AppPreferences.get(AppPreferences.prefColor) ?? colorMode;
  }

  void saveEncryption(newValue) {
    if (hasEncrypted) {
      return;
    }
    setState(() => isEncrypted = newValue);
    AppPreferences.set(AppPreferences.prefDoEncrypt, isEncrypted ? 'true' : 'false');
  }

  Future<void> saveCurrency(Currency? value) async {
    await AppPreferences.set(AppPreferences.prefCurrency, value!.code);
    setState(() => currency = value);
  }

  Future<void> saveTheme(String value) async {
    await theme.setTheme(value);
    setState(() => brightness = value);
  }

  Future<void> saveColor(String value) async {
    await palette.setMode(value);
    setState(() => colorMode = value);
  }

  Future<void> saveLocale(String value) async {
    await locale.set(value);
    setState(() {});
  }

  Future<void> changePalette(_) async {
    await palette.set(paletteState.light, paletteState.dark);
    setState(() => paletteState);
  }

  Future<void> initCurrencyFromLocale(String locale) async {
    final format = NumberFormat.simpleCurrency(locale: locale);
    String? code = AppPreferences.get(AppPreferences.prefCurrency);
    if (code == null && format.currencyName != null) {
      await AppPreferences.set(AppPreferences.prefCurrency, format.currencyName!);
      code = format.currencyName!;
    }
    setState(() => currency = CurrencyProvider.find(code));
  }

  @override
  String getButtonTitle() => AppLocale.labels.saveSettingsTooltip;

  @override
  Widget buildContent(BuildContext context, BoxConstraints constraints) {
    theme = Provider.of<AppTheme>(context, listen: false);
    zoom = Provider.of<AppZoom>(context, listen: false);
    palette = Provider.of<AppPalette>(context, listen: false);
    locale = Provider.of<AppLocale>(context, listen: false);
    final TextTheme textTheme = context.textTheme;
    double indent = ThemeHelper.getIndent(2);
    if (currency == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => initCurrencyFromLocale(AppLocale.code));
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThemeHelper.hIndent2x,
          Text(
            AppLocale.labels.language,
            style: textTheme.bodyLarge,
          ),
          ListSelector(
            value: AppLocale.code,
            hintText: AppLocale.labels.language,
            options: [
              ListSelectorItem(id: 'en', name: AppLocale.labels.languageEn),
              ListSelectorItem(id: 'be', name: AppLocale.labels.languageBe),
              ListSelectorItem(id: 'be_EU', name: AppLocale.labels.languageBeEu),
            ],
            setState: saveLocale,
          ),
          ThemeHelper.hIndent2x,
          Text(
            AppLocale.labels.currencyDefault,
            style: textTheme.bodyLarge,
          ),
          BaseCurrencySelector(
            value: currency?.code,
            textTheme: context.textTheme,
            colorScheme: context.colorScheme,
            update: saveCurrency,
          ),
          ThemeHelper.hIndent2x,
          if (kDebugMode) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  AppLocale.labels.encryptionMode,
                  style: textTheme.bodyLarge,
                ),
                Switch(
                  value: isEncrypted,
                  onChanged: saveEncryption,
                ),
                Expanded(
                  child: hasEncrypted ? Text(AppLocale.labels.hasEncrypted) : ThemeHelper.emptyBox,
                ),
              ],
            ),
            ThemeHelper.hIndent2x,
          ],
          Text(
            AppLocale.labels.brightnessTheme,
            style: textTheme.bodyLarge,
          ),
          ListSelector(
            value: brightness,
            hintText: AppLocale.labels.brightnessTheme,
            options: [
              ListSelectorItem(id: '0', name: AppLocale.labels.systemMode),
              ListSelectorItem(id: '1', name: AppLocale.labels.lightMode),
              ListSelectorItem(id: '2', name: AppLocale.labels.darkMode),
            ],
            setState: saveTheme,
          ),
          ThemeHelper.hIndent2x,
          Text(
            AppLocale.labels.colorTheme,
            style: textTheme.bodyLarge,
          ),
          ListSelector(
            value: colorMode,
            hintText: AppLocale.labels.colorTheme,
            options: [
              ListSelectorItem(id: AppColors.colorApp, name: AppLocale.labels.colorApp),
              ListSelectorItem(id: AppColors.colorSystem, name: AppLocale.labels.colorSystem),
              ListSelectorItem(id: AppColors.colorUser, name: AppLocale.labels.colorUser),
            ],
            setState: saveColor,
          ),
          ThemeHelper.hIndent2x,
          if (colorMode == AppColors.colorUser) ...[
            TableWidget(
              width: constraints.maxWidth - 2 * indent,
              shadowColor: context.colorScheme.onBackground.withOpacity(0.05),
              chunk: const [120, null, null],
              data: [
                [
                  Text(AppLocale.labels.colorType),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocale.labels.colorLight),
                      IconButton(
                        onPressed: () =>
                            changePalette(paletteState = (light: AppDefaultColors(), dark: paletteState.dark)),
                        icon: const Icon(Icons.restore),
                        tooltip: AppLocale.labels.colorRestore,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocale.labels.colorDark),
                      IconButton(
                        onPressed: () =>
                            changePalette(paletteState = (light: paletteState.light, dark: AppDarkColors())),
                        icon: const Icon(Icons.restore),
                        tooltip: AppLocale.labels.colorRestore,
                      ),
                    ],
                  ),
                ],
                [
                  Text(AppLocale.labels.colorPrimary),
                  ColorSelector(
                      value: paletteState.light.primary.toMaterialColor,
                      setState: (v) => changePalette(paletteState.light.primary = v)),
                  ColorSelector(
                      value: paletteState.dark.primary.toMaterialColor,
                      setState: (v) => changePalette(paletteState.dark.primary = v)),
                ],
                [
                  Text(AppLocale.labels.colorInversePrimary),
                  ColorSelector(
                      value: paletteState.light.inversePrimary.toMaterialColor,
                      setState: (v) => changePalette(paletteState.light.inversePrimary = v)),
                  ColorSelector(
                      value: paletteState.dark.inversePrimary.toMaterialColor,
                      setState: (v) => changePalette(paletteState.dark.inversePrimary = v)),
                ],
                [
                  Text(AppLocale.labels.colorInverseSurface),
                  ColorSelector(
                      value: paletteState.light.inverseSurface.toMaterialColor,
                      setState: (v) => changePalette(paletteState.light.inverseSurface = v)),
                  ColorSelector(
                      value: paletteState.dark.inverseSurface.toMaterialColor,
                      setState: (v) => changePalette(paletteState.dark.inverseSurface = v)),
                ],
                [
                  Text(AppLocale.labels.colorSecondary),
                  ColorSelector(
                      value: paletteState.light.secondary.toMaterialColor,
                      setState: (v) => changePalette(paletteState.light.secondary = v)),
                  ColorSelector(
                      value: paletteState.dark.secondary.toMaterialColor,
                      setState: (v) => changePalette(paletteState.dark.secondary = v)),
                ],
                [
                  Text(AppLocale.labels.colorOnSecondary),
                  ColorSelector(
                      value: paletteState.light.onSecondary.toMaterialColor,
                      setState: (v) => changePalette(paletteState.light.onSecondary = v)),
                  ColorSelector(
                      value: paletteState.dark.onSecondary.toMaterialColor,
                      setState: (v) => changePalette(paletteState.dark.onSecondary = v)),
                ],
                [
                  Text(AppLocale.labels.colorOnSecondaryContainer),
                  ColorSelector(
                      value: paletteState.light.onSecondaryContainer.toMaterialColor,
                      setState: (v) => changePalette(paletteState.light.onSecondaryContainer = v)),
                  ColorSelector(
                      value: paletteState.dark.onSecondaryContainer.toMaterialColor,
                      setState: (v) => changePalette(paletteState.dark.onSecondaryContainer = v)),
                ],
              ],
            ),
            ThemeHelper.hIndent4x,
          ],
          Text(
            AppLocale.labels.zoomState,
            style: textTheme.bodyLarge,
          ),
          Container(
            color: context.colorScheme.fieldBackground,
            child: Slider(
              value: zoom.value,
              onChanged: zoom.set,
              min: AppZoom.min,
              max: AppZoom.max,
              divisions: 15,
              label: zoom.value.toStringAsFixed(2),
            ),
          ),
          ThemeHelper.hIndent2x,
        ],
      ),
    );
  }
}
