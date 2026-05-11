import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared_cart_models.dart';

class SharedCartStore {
  static const _storageKey = 'shared_cart_feature_items';

  final RxList<SharedCartItem> items = <SharedCartItem>[].obs;
  bool _loaded = false;

  double get totalPrice {
    return items.fold<double>(0, (total, item) => total + item.subtotal);
  }

  int get totalQuantity {
    return items.fold<int>(0, (total, item) => total + item.quantity);
  }

  Future<void> load() async {
    if (_loaded) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final rawItems = prefs.getString(_storageKey);
    if (rawItems == null || rawItems.isEmpty) {
      _loaded = true;
      return;
    }

    final decoded = jsonDecode(rawItems) as List<dynamic>;
    items.assignAll(
      decoded.map(
        (item) =>
            SharedCartItem.fromJson(Map<String, dynamic>.from(item as Map)),
      ),
    );
    _loaded = true;
  }

  Future<void> addProduct(SharedCartProduct product) async {
    await load();
    final index = items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      final current = items[index];
      items[index] = current.copyWith(quantity: current.quantity + 1);
    } else {
      items.add(SharedCartItem(product: product, quantity: 1));
    }
    await _save();
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    await load();
    final index = items.indexWhere((item) => item.product.id == productId);
    if (index < 0) {
      return;
    }

    if (quantity <= 0) {
      items.removeAt(index);
    } else {
      items[index] = items[index].copyWith(quantity: quantity);
    }
    await _save();
  }

  Future<void> removeProduct(String productId) async {
    await load();
    items.removeWhere((item) => item.product.id == productId);
    await _save();
  }

  Future<void> clear() async {
    await load();
    items.clear();
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
