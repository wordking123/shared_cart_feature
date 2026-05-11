import 'package:flutter/material.dart';

import 'shared_cart_entry_page.dart';
import 'shared_cart_host.dart';
import 'shared_cart_internal_routes.dart';
import 'shared_cart_store.dart';

class SharedCartFeature {
  static const entryRoute = '/shared-cart';
  static const descriptionEntryRoute = '/shared-cart-description';
  static const cartPage = SharedCartInternalRoutes.cart;
  static const descriptionPage = SharedCartInternalRoutes.description;

  static final SharedCartStore cart = SharedCartStore();
  static SharedCartHost? _host;

  static SharedCartHost get host {
    final value = _host;
    if (value == null) {
      throw StateError('SharedCartFeature.install must be called first.');
    }
    return value;
  }

  static void install({required SharedCartHost host}) {
    _host = host;
  }

  static Widget entry({String initialPage = cartPage, String? description}) {
    return SharedCartEntryPage(
      initialPage: initialPage,
      description: description,
    );
  }
}
