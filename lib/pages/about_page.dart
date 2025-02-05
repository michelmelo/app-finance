// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'package:app_finance/_classes/herald/app_locale.dart';
import 'package:app_finance/_configs/theme_helper.dart';
import 'package:app_finance/_ext/build_context_ext.dart';
import 'package:app_finance/_mixins/launcher_mixin.dart';
import 'package:app_finance/pages/abstract_page_state.dart';
import 'package:app_finance/widgets/wrapper/row_widget.dart';
import 'package:app_finance/widgets/wrapper/text_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  AboutPageState createState() => AboutPageState();
}

class AboutPageState extends AbstractPageState<AboutPage> with LauncherMixin {
  String version = '';
  String buildNumber = '';

  @override
  void initState() {
    PackageInfo.fromPlatform().then((PackageInfo value) {
      setState(() {
        version = value.version;
        buildNumber = value.buildNumber;
      });
    });
    super.initState();
  }

  @override
  String getTitle() {
    return AppLocale.labels.aboutHeadline;
  }

  @override
  String getButtonName() => '';

  @override
  Widget buildButton(BuildContext context, BoxConstraints constraints) {
    return ThemeHelper.emptyBox;
  }

  @override
  Widget buildContent(BuildContext context, BoxConstraints constraints) {
    double indent = ThemeHelper.getIndent();
    double width = ThemeHelper.getWidth(context, 2, constraints);
    final locale = AppLocale.labels.localeName;
    return Padding(
      padding: EdgeInsets.fromLTRB(indent, indent, indent, 0),
      child: Column(
        children: [
          RowWidget(
            alignment: MainAxisAlignment.spaceEvenly,
            indent: indent,
            maxWidth: width,
            chunk: const [60, null, null],
            children: [
              [
                Image.asset(
                  'assets/images/logo.png',
                  width: 60,
                  height: 60,
                ),
              ],
              [
                TextWrapper(
                  AppLocale.labels.appTitle,
                  style: context.textTheme.headlineLarge,
                ),
              ],
              [
                TextWrapper(AppLocale.labels.appVersion(version)),
                TextWrapper(AppLocale.labels.appBuild(buildNumber)),
              ],
            ],
          ),
          const Divider(),
          RowWidget(
            indent: indent,
            maxWidth: width,
            alignment: MainAxisAlignment.spaceEvenly,
            chunk: const [null, null, null],
            children: [
              [
                ElevatedButton(
                  onPressed: () => openURL('https://github.com/lyskouski/app-finance/releases'),
                  child: Text(AppLocale.labels.releases, overflow: TextOverflow.ellipsis),
                ),
              ],
              [
                Center(
                  child: ElevatedButton(
                    onPressed: () => openURL('https://github.com/users/lyskouski/projects/2/views/1'),
                    child: Text(AppLocale.labels.roadmap, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
              [
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => openURL('https://github.com/lyskouski/app-finance/milestones'),
                    child: Text(AppLocale.labels.milestones, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ],
          ),
          const Divider(),
          Expanded(
            child: FutureBuilder(
              future: DefaultAssetBundle.of(context).loadString('./assets/l10n/privacy_policy_$locale.md'),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Markdown(data: snapshot.data ?? '');
                }
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }
}
