import 'package:shopx/domain/products/product.dart';

class CartItem {
  final Product product;
  final double quantity;
   final double sellingPrice; // 👈 NEW

  const CartItem({
    required this.product,
    required this.quantity,
    required this.sellingPrice
  });

  CartItem copyWith({
    Product? product,
    double? quantity,
    double? sellingPrice,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
       sellingPrice: sellingPrice ?? this.sellingPrice,
    );
  }
}

class CartState {
  final List<CartItem> items;
  final bool isProcessing;
  final String? error;

  const CartState({
    required this.items,
    this.isProcessing = false,
    this.error,
  });

  double get totalPrice {
    double sum = 0;
    for (final item in items) {
      sum += item.sellingPrice * item.quantity;
    }
    return sum;
  }

  CartState copyWith({
    List<CartItem>? items,
    bool? isProcessing,
    String? error,
  }) {
    return CartState(
      items: items ?? this.items,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
    );
  }
}
