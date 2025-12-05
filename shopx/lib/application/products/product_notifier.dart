import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopx/application/auth/auth_notifier.dart';
import 'package:shopx/application/products/product_state.dart';
import 'package:shopx/domain/products/product.dart';
import 'package:shopx/infrastructure/products/product_repository.dart';
import 'package:shopx/infrastructure/products/product_api.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.read(productApiProvider));
});

class ProductNotifier extends Notifier<ProductState> {
  @override
  ProductState build() {
    return ProductState();  
  }

  // 1️⃣ Create product + upload images
  Future<void> createProduct(Product product, List<Uint8List> images) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await ref.read(productRepositoryProvider)
          .createProduct(product, images);

      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 2️⃣ Fetch all products
  Future<void> fetchProducts() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final products = await ref.read(productRepositoryProvider).getProducts();
      state = state.copyWith(isLoading: false, products: products);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 3️⃣ Update product (no token required)
  Future<void> updateProduct(String id, Product product) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await ref.read(productRepositoryProvider).updateProduct(id, product);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 4️⃣ Delete product
  Future<void> deleteProduct(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await ref.read(productRepositoryProvider).deleteProduct(id);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final productNotifierProvider =
    NotifierProvider<ProductNotifier, ProductState>(ProductNotifier.new);
