// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be
// found in the LICENSE file.

import 'package:app_finance/_classes/app_theme.dart';
import 'package:app_finance/_mixins/shared_preferences_mixin.dart';
import 'package:app_finance/custom_text_theme.dart';
import 'package:app_finance/_classes/app_data.dart';
import 'package:app_finance/_classes/app_route.dart';
import 'package:app_finance/firebase_options.dart';
import 'package:app_finance/routes/about_page.dart';
import 'package:app_finance/routes/account_add_page.dart';
import 'package:app_finance/routes/account_edit_page.dart';
import 'package:app_finance/routes/account_view_page.dart';
import 'package:app_finance/routes/account_page.dart';
import 'package:app_finance/routes/bill_add_page.dart';
import 'package:app_finance/routes/bill_edit_page.dart';
import 'package:app_finance/routes/bill_page.dart';
import 'package:app_finance/routes/bill_view_page.dart';
import 'package:app_finance/routes/budget_page.dart';
import 'package:app_finance/routes/budget_add_page.dart';
import 'package:app_finance/routes/budget_edit_page.dart';
import 'package:app_finance/routes/budget_view_page.dart';
import 'package:app_finance/routes/currency_page.dart';
import 'package:app_finance/routes/goal_add_page.dart';
import 'package:app_finance/routes/goal_edit_page.dart';
import 'package:app_finance/routes/goal_page.dart';
import 'package:app_finance/routes/goal_view_page.dart';
import 'package:app_finance/routes/home_page.dart';
import 'package:app_finance/routes/settings_page.dart';
import 'package:app_finance/routes/start_page.dart';
import 'package:app_finance/routes/subscription_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final platform = DefaultFirebaseOptions.currentPlatform;
  if (platform != null) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseAnalytics.instance.logAppOpen();
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseAnalytics.instance.logSelectContent(contentType: error.toString(), itemId: 'platform-error');
      return true;
    };
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      FirebaseAnalytics.instance.logSelectContent(contentType: details.toString(), itemId: 'flutter-error');
    };
  }
  SharedPreferencesMixin.pref = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppData>(
          create: (_) => AppData(),
        ),
        ChangeNotifierProvider<AppTheme>(
          create: (_) => AppTheme(ThemeMode.system),
        ),
      ],
      child: MyApp(platform: platform),
    ),
  );
}

class MyApp extends StatefulWidget {
  final FirebaseOptions? platform;
  const MyApp({super.key, this.platform});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  String route = AppRoute.homeRoute;

  WidgetBuilder? getDynamicRouterWidget(String route) {
    final regex = RegExp(r'\/uuid:([\w-]+)');
    final match = regex.firstMatch(route);
    if (widget.platform != null) {
      FirebaseAnalytics.instance.logSelectContent(contentType: route, itemId: match != null ? 'dynamic' : 'static');
    }
    if (match != null) {
      final String uuid = match.group(1) ?? '';
      switch (route.replaceAll(uuid, '')) {
        case AppRoute.accountViewRoute:
          return (context) => AccountViewPage(uuid: uuid);
        case AppRoute.accountEditRoute:
          return (context) => AccountEditPage(uuid: uuid);
        case AppRoute.budgetViewRoute:
          return (context) => BudgetViewPage(uuid: uuid);
        case AppRoute.budgetEditRoute:
          return (context) => BudgetEditPage(uuid: uuid);
        case AppRoute.billViewRoute:
          return (context) => BillViewPage(uuid: uuid);
        case AppRoute.billEditRoute:
          return (context) => BillEditPage(uuid: uuid);
        case AppRoute.goalViewRoute:
          return (context) => GoalViewPage(uuid: uuid);
        case AppRoute.goalEditRoute:
          return (context) => GoalEditPage(uuid: uuid);
      }
    }
    final staticRoutes = <String, WidgetBuilder>{
      AppRoute.aboutRoute: (context) => AboutPage(),
      AppRoute.accountAddRoute: (context) => AccountAddPage(),
      AppRoute.accountRoute: (context) => AccountPage(),
      AppRoute.billAddRoute: (context) => BillAddPage(),
      AppRoute.billRoute: (context) => BillPage(),
      AppRoute.budgetAddRoute: (context) => BudgetAddPage(),
      AppRoute.budgetRoute: (context) => BudgetPage(),
      AppRoute.currencyRoute: (context) => CurrencyPage(),
      AppRoute.goalAddRoute: (context) => GoalAddPage(),
      AppRoute.goalRoute: (context) => GoalPage(),
      AppRoute.homeRoute: (context) => HomePage(),
      AppRoute.settingsRoute: (context) => SettingsPage(),
      AppRoute.startRoute: (context) => StartPage(),
      AppRoute.subscriptionRoute: (context) => SubscriptionPage(),
    };
    if (staticRoutes.containsKey(route)) {
      return staticRoutes[route];
    }
    return (context) => HomePage();
  }

  MaterialPageRoute? getDynamicRouter(settings) {
    route = settings.name!;
    return MaterialPageRoute(builder: getDynamicRouterWidget(route)!);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        brightness: Brightness.light,
        textTheme: CustomTextTheme.textTheme(Theme.of(context)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        textTheme: CustomTextTheme.textTheme(Theme.of(context)),
        useMaterial3: true,
      ),
      themeMode: context.watch<AppTheme>().value,
      home: HomePage(),
      onGenerateRoute: getDynamicRouter,
    );
  }
}