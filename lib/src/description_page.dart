import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'shared_cart_feature.dart';
import 'shared_cart_models.dart';
import 'shared_cart_navigation.dart';

class SharedCartDescriptionPage extends StatefulWidget {
  const SharedCartDescriptionPage({
    super.key,
    required this.navigatorId,
    this.description,
  });

  final int navigatorId;
  final String? description;

  @override
  State<SharedCartDescriptionPage> createState() =>
      _SharedCartDescriptionPageState();
}

class _SharedCartDescriptionPageState extends State<SharedCartDescriptionPage> {
  SharedCartUser? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await SharedCartFeature.host.getCurrentUser();
    if (mounted) {
      setState(() => _user = user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => SharedCartNavigation.back(context),
        ),
        title: const Text('购物车说明'),
      ),
      body: Obx(() {
        final totalQuantity = SharedCartFeature.cart.totalQuantity;
        final totalPrice = SharedCartFeature.cart.totalPrice;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '公共模块页面',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.description ??
                          '这是公共模块内部的说明页，可从宿主项目直接进入，也可从购物车内部进入。',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(_user == null ? '当前未登录' : _user!.name),
                subtitle: Text(
                  _user == null ? '结算时会请求宿主项目登录' : '来源：${_user!.channel}',
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.shopping_cart_outlined),
                title: Text('当前购物车 $totalQuantity 件商品'),
                subtitle: Text('合计 ¥${totalPrice.toStringAsFixed(2)}'),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => SharedCartNavigation.back(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('返回上一页'),
            ),
          ],
        );
      }),
    );
  }
}
