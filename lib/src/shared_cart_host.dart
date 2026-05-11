import 'shared_cart_models.dart';

abstract interface class SharedCartHost {
  Future<SharedCartUser?> getCurrentUser();

  Future<bool> requestLogin();

  Future<void> openProductDetail(String productId);

  Future<String> createPaidOrder(List<SharedCartItem> items);

  Future<void> openOrderDetail(String orderId);
}
