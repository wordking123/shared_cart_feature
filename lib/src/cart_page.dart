import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'shared_cart_feature.dart';
import 'shared_cart_models.dart';
import 'shared_cart_navigation.dart';

class SharedCartPage extends StatefulWidget {
  const SharedCartPage({super.key, required this.navigatorId});

  final int navigatorId;

  @override
  State<SharedCartPage> createState() => _SharedCartPageState();
}

class _SharedCartPageState extends State<SharedCartPage> {
  late final String _tag = 'shared-cart-${widget.navigatorId}';
  late final SharedCartController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(SharedCartController(), tag: _tag);
  }

  @override
  void dispose() {
    Get.delete<SharedCartController>(tag: _tag, force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => SharedCartNavigation.back(context),
        ),
        title: const Text('共享购物车'),
        actions: [
          IconButton(
            tooltip: '购物车说明',
            onPressed: () => SharedCartNavigation.openDescription(
              context,
              description: '从购物车内部进入说明页，当前模块内部导航栈应能正确返回购物车。',
            ),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final user = _controller.user.value;
          final items = SharedCartFeature.cart.items;

          return Column(
            children: [
              _UserBanner(user: user),
              Expanded(
                child: items.isEmpty
                    ? const _EmptyCart()
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _CartItemTile(
                            item: item,
                            onTap: () =>
                                _controller.openProduct(item.product.id),
                            onDecrease: () => _controller.updateQuantity(
                              item.product.id,
                              item.quantity - 1,
                            ),
                            onIncrease: () => _controller.updateQuantity(
                              item.product.id,
                              item.quantity + 1,
                            ),
                            onRemove: () => _controller.remove(item.product.id),
                          );
                        },
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemCount: items.length,
                      ),
              ),
              _CheckoutBar(
                total: SharedCartFeature.cart.totalPrice,
                quantity: SharedCartFeature.cart.totalQuantity,
                checkingOut: _controller.checkingOut.value,
                onCheckout: () => _controller.checkout(context),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class SharedCartController extends GetxController {
  final Rxn<SharedCartUser> user = Rxn<SharedCartUser>();
  final RxBool checkingOut = false.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    await SharedCartFeature.cart.load();
    user.value = await SharedCartFeature.host.getCurrentUser();
  }

  Future<void> openProduct(String productId) async {
    await SharedCartFeature.host.openProductDetail(productId);
    user.value = await SharedCartFeature.host.getCurrentUser();
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    await SharedCartFeature.cart.updateQuantity(productId, quantity);
  }

  Future<void> remove(String productId) async {
    await SharedCartFeature.cart.removeProduct(productId);
  }

  Future<void> checkout(BuildContext context) async {
    if (SharedCartFeature.cart.items.isEmpty) {
      _showMessage(context, '购物车为空');
      return;
    }

    var currentUser = await SharedCartFeature.host.getCurrentUser();
    if (currentUser == null) {
      final loggedIn = await SharedCartFeature.host.requestLogin();
      if (!loggedIn) {
        if (!context.mounted) {
          return;
        }
        _showMessage(context, '登录后才能结算');
        return;
      }
      currentUser = await SharedCartFeature.host.getCurrentUser();
    }

    if (currentUser == null) {
      if (!context.mounted) {
        return;
      }
      _showMessage(context, '登录状态异常，请重试');
      return;
    }

    user.value = currentUser;
    checkingOut.value = true;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      final orderId = await SharedCartFeature.host.createPaidOrder(
        SharedCartFeature.cart.items.toList(growable: false),
      );
      await SharedCartFeature.cart.clear();
      if (context.mounted) {
        _showMessage(context, '支付成功，已生成订单');
      }
      await SharedCartFeature.host.openOrderDetail(orderId);
    } finally {
      checkingOut.value = false;
    }
  }

  void _showMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }
}

class _UserBanner extends StatelessWidget {
  const _UserBanner({required this.user});

  final SharedCartUser? user;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user == null ? '未登录用户' : '${user!.name} 的购物车',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(user == null ? '结算时会跳转到宿主项目登录页' : '账号来源：${user!.channel}'),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('购物车暂无商品，请从主项目商品详情页加入'));
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.item,
    required this.onTap,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });

  final SharedCartItem item;
  final VoidCallback onTap;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.product.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: '移除',
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
              Text(item.product.description),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('¥${item.product.price.toStringAsFixed(2)}'),
                  const Spacer(),
                  IconButton(
                    onPressed: onDecrease,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('${item.quantity}'),
                  IconButton(
                    onPressed: onIncrease,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({
    required this.total,
    required this.quantity,
    required this.checkingOut,
    required this.onCheckout,
  });

  final double total;
  final int quantity;
  final bool checkingOut;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: const [BoxShadow(blurRadius: 12, color: Color(0x22000000))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '共 $quantity 件，合计 ¥${total.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          FilledButton(
            onPressed: checkingOut ? null : onCheckout,
            child: checkingOut
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('结算'),
          ),
        ],
      ),
    );
  }
}
