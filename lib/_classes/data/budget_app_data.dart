// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be
// found in the LICENSE file.

import 'package:app_finance/_classes/data/abstract_app_data.dart';
import 'package:app_finance/data.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class BudgetAppData extends AbstractAppData {
  BudgetAppData({
    required super.title,
    super.uuid,
    super.progress = 0.0,
    super.color,
    super.icon,
    super.currency,
    super.updatedAt,
    super.createdAt,
    super.createdAtFormatted,
    amountLimit,
    super.hidden,
  }) : super(
          details: amountLimit,
        );

  @override
  AppDataType getType() => AppDataType.budgets;

  @override
  BudgetAppData clone() {
    return BudgetAppData(
      title: super.title,
      uuid: super.uuid,
      progress: super.progress,
      color: super.color,
      icon: super.icon,
      currency: super.currency,
      createdAt: super.createdAt,
      amountLimit: amountLimit,
      hidden: super.hidden,
    );
  }

  factory BudgetAppData.fromJson(Map<String, dynamic> json) {
    return BudgetAppData(
      title: json['title'],
      uuid: json['uuid'],
      progress: json['progress'],
      color: json['color'] != null
          ? MaterialColor(json['color'], const <int, Color>{})
          : null,
      icon: json['icon'] != null
          ? IconData(json['icon'], fontFamily: 'MaterialIcons')
          : null,
      currency: json['currency'] != null
          ? CurrencyService().findByCode(json['currency'])
          : null,
      updatedAt: DateTime.parse(json['updatedAt']),
      createdAt: DateTime.parse(json['createdAt']),
      amountLimit: json['amountLimit'],
      hidden: json['hidden'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'amountLimit': amountLimit,
      };

  @override
  double get details => super.details * (1 - super.progress);

  String get detailsFormatted {
    String left = AppLocalizations.of(getContext()!)!.left;
    return '${getNumberFormatted(details)} $left';
  }

  double get amountLimit => super.details;
  set amountLimit(double value) => super.details = value;

  @override
  String get description => getContext() != null
      ? '${getNumberFormatted(super.details * super.progress)} / ${getNumberFormatted(super.details)}'
      : '';

  @override
  set description(String? value) => {};
}