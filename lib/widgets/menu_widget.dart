// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be
// found in the LICENSE file.

import 'package:app_finance/routes.dart' as routes;
import 'package:flutter/material.dart';

class MenuWidget extends StatelessWidget {
  int index;
  int selectedIndex;
  Function setState;

  MenuWidget({
    super.key,
    required this.index,
    required this.selectedIndex,
    required this.setState,
  });

  void _navigateToPage(BuildContext context, String routeName) {
    Navigator.pop(context);
    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    Color color =
        selectedIndex == index ? colorScheme.primary : colorScheme.secondary;

    return InkWell(
      child: ListTile(
        leading: Icon(
          routes.menuList[index].icon,
          color: color,
        ),
        title: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Text(
            routes.menuList[index].name,
            style: textTheme.bodyMedium?.copyWith(color: color),
          ),
        ),
      ),
      onTap: () {
        setState();
        _navigateToPage(context, routes.menuList[index].route);
      },
      onHover: (isHovered) {
        if (isHovered) {
          setState();
        }
      },
    );
  }
}