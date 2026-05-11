import 'package:flutter/material.dart';

import 'shared_cart_internal_routes.dart';

class SharedCartDescriptionArguments {
  const SharedCartDescriptionArguments({this.description});

  final String? description;
}

class SharedCartNavigation {
  const SharedCartNavigation._();

  static Future<void> back(BuildContext context) async {
    final innerNavigator = Navigator.of(context);
    if (innerNavigator.canPop()) {
      innerNavigator.pop();
      return;
    }

    final hostNavigator = Navigator.of(context, rootNavigator: true);
    if (hostNavigator.canPop()) {
      hostNavigator.pop();
    }
  }

  static Future<T?> openDescription<T>(
    BuildContext context, {
    String? description,
  }) {
    return Navigator.of(context).pushNamed<T>(
      SharedCartInternalRoutes.description,
      arguments: SharedCartDescriptionArguments(description: description),
    );
  }
}
