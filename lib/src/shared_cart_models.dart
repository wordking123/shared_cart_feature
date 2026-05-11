class SharedCartUser {
  const SharedCartUser({
    required this.id,
    required this.name,
    required this.channel,
  });

  final String id;
  final String name;
  final String channel;
}

class SharedCartProduct {
  const SharedCartProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
  });

  factory SharedCartProduct.fromJson(Map<String, dynamic> json) {
    return SharedCartProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String? ?? '',
    );
  }

  final String id;
  final String name;
  final double price;
  final String description;

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'price': price, 'description': description};
  }
}

class SharedCartItem {
  const SharedCartItem({required this.product, required this.quantity});

  factory SharedCartItem.fromJson(Map<String, dynamic> json) {
    return SharedCartItem(
      product: SharedCartProduct.fromJson(
        Map<String, dynamic>.from(json['product'] as Map),
      ),
      quantity: json['quantity'] as int,
    );
  }

  final SharedCartProduct product;
  final int quantity;

  double get subtotal => product.price * quantity;

  SharedCartItem copyWith({SharedCartProduct? product, int? quantity}) {
    return SharedCartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {'product': product.toJson(), 'quantity': quantity};
  }
}
