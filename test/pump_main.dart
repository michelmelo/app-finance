// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'dart:io';

import 'package:app_finance/_classes/herald/app_sync.dart';
import 'package:app_finance/_classes/storage/app_data.dart';
import 'package:app_finance/_classes/herald/app_locale.dart';
import 'package:app_finance/_classes/herald/app_theme.dart';
import 'package:app_finance/_classes/gen/generate_with_method_setters.dart';
import 'package:app_finance/_configs/custom_text_theme.dart';
import 'package:app_finance/_mixins/shared_preferences_mixin.dart';
import 'package:app_finance/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'e2e/_steps/screen_capture.dart';

@GenerateNiceMocks([MockSpec<SharedPreferences>()])
import 'pump_main.mocks.dart';
@GenerateWithMethodSetters([MockSharedPreferences])
import 'pump_main.wrapper.dart';

class PumpMain {
  static const path = './coverage/data';

  static Future<void> init(WidgetTester tester, [bool isIntegration = false]) async {
    final pumpMain = PumpMain();
    wrapProvider(tester, 'plugins.flutter.io/path_provider', '$path/${UniqueKey()}');
    await pumpMain.initPref(isIntegration);
    await pumpMain.initMain(tester, isIntegration);
  }

  static Future<void> initFont(String name) async {
    final Future<ByteData> fontData = rootBundle.load('assets/fonts/$name.ttf');
    final FontLoader fontLoader = FontLoader(name)..addFont(fontData);
    await fontLoader.load();
  }

  static Future<void> initPaint(WidgetTester tester, CustomPainter paint, [Size size = const Size(320, 240)]) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;

    await initFont('Abel-Regular');
    await initFont('RobotoCondensed-Regular');

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          brightness: Brightness.light,
          textTheme: CustomTextTheme.textTheme(ThemeData.light()),
          useMaterial3: true,
        ),
        home: CustomPaint(
          size: size,
          painter: paint,
        ),
      ),
    );
  }

  AppData getStore(AppSync appSync, bool isIntegration) {
    final appData = AppData(appSync);
    if (!isIntegration) {
      appData.isLoading = false;
    }
    return appData;
  }

  static void cleanUpData() {
    final dir = Directory(path);
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  }

  static void wrapProvider(WidgetTester tester, String channel, String output) {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      MethodChannel(channel),
      (MethodCall methodCall) => Future.value(output),
    );
  }

  Future<void> initPref(bool isIntegration) async {
    if (isIntegration) {
      SharedPreferencesMixin.pref = await SharedPreferences.getInstance();
    } else {
      final pref = WrapperMockSharedPreferences();
      pref.mockGetString = (value) => '';
      SharedPreferencesMixin.pref = pref;
    }
  }

  Future<void> initMain(WidgetTester tester, bool isIntegration) async {
    final appSync = AppSync();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<AppSync>(
          create: (_) => appSync,
        ),
        ChangeNotifierProvider<AppData>(
          create: (_) => getStore(appSync, isIntegration),
        ),
        ChangeNotifierProvider<AppTheme>(
          create: (_) => AppTheme(ThemeMode.system),
        ),
        ChangeNotifierProvider<AppLocale>(
          create: (_) => AppLocale(AppLocale.fromCode('en')),
        ),
      ],
      child: RepaintBoundary(
        key: ScreenCapture.getKey(),
        child: const MyApp(),
      ),
    ));
  }
}