import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'cart_page.dart';
import 'description_page.dart';
import 'shared_cart_internal_routes.dart';
import 'shared_cart_navigation.dart';

class SharedCartEntryPage extends StatefulWidget {
  const SharedCartEntryPage({
    super.key,
    required this.initialPage,
    this.description,
  });

  final String initialPage;
  final String? description;

  @override
  State<SharedCartEntryPage> createState() => _SharedCartEntryPageState();
}

class _SharedCartEntryPageState extends State<SharedCartEntryPage> {
  static int _nextNavigatorId = 9000;
  late final int _navigatorId = _nextNavigatorId++;

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }

        final innerNavigator = Get.nestedKey(_navigatorId)?.currentState;
        if (innerNavigator != null && innerNavigator.canPop()) {
          innerNavigator.pop();
          return;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      },
      child: Navigator(
        key: Get.nestedKey(_navigatorId),
        initialRoute: widget.initialPage,
        onGenerateInitialRoutes: (navigator, initialRoute) {
          return [_onGenerateRoute(RouteSettings(name: initialRoute))];
        },
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SharedCartInternalRoutes.cart:
        return GetPageRoute<void>(
          settings: settings,
          page: () => SharedCartPage(navigatorId: _navigatorId),
        );
      case SharedCartInternalRoutes.description:
        final arguments = settings.arguments;
        final description = arguments is SharedCartDescriptionArguments
            ? arguments.description
            : widget.description;
        return GetPageRoute<void>(
          settings: settings,
          page: () => SharedCartDescriptionPage(
            navigatorId: _navigatorId,
            description: description,
          ),
        );
      default:
        return GetPageRoute<void>(
          settings: settings,
          page: () => SharedCartPage(navigatorId: _navigatorId),
        );
    }
  }
}
