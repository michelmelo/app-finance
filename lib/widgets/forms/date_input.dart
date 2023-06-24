// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateInput extends StatelessWidget {
  Function setState;
  DateTime? value;
  TextStyle? style;

  DateInput({
    super.key,
    required this.setState,
    required this.value,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final DateFormat formatterDate = DateFormat.yMd(locale);
    DateTime currentDate = DateTime.now();
    const Duration dateRange = Duration(days: 20 * 365);
    DateTime firstDate = currentDate.subtract(dateRange);
    DateTime lastDate = currentDate.add(dateRange);

    return Container(
      color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.3),
      child: ListTile(
        title: Text(
          value != null ? formatterDate.format(value!) : 'Select date',
          style: style,
        ),
        onTap: () async {
          final DateTime? selectedDate = await showDatePicker(
            context: context,
            initialDate: value ?? currentDate,
            firstDate: firstDate,
            lastDate: lastDate,
          );
          if (selectedDate != null) {
            DateTime date = selectedDate.add(Duration(
              hours: value?.hour ?? 0,
              minutes: value?.minute ?? 0,
              seconds: value?.second ?? 0,
            ));
            setState(date);
          }
        },
      ),
    );
  }
}