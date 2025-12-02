import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopx/application/auth/auth_notifier.dart';
import 'package:shopx/application/products/product_state.dart';
import 'package:shopx/domain/products/product.dart';
import 'package:shopx/infrastructure/products/product_repository.dart';
import 'package:shopx/infrastructure/products/product_api.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ProductApi());
});

// ⭐ NEW API – same as your AuthNotifier
class ProductNotifier extends Notifier<ProductState> {
  @override
  ProductState build() {
    return ProductState(); // initial state
  }

  Future<void> addProduct(Product product) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // ⭐ get token from auth provider
      final auth = ref.read(authNotifierProvider);
      final token = auth.token??""; //Get from AuthState, not UserModel

      await ref.read(productRepositoryProvider)
          .addProduct(product, token);

      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchProducts() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final products = await ref.read(productRepositoryProvider).getProducts();
      state = state.copyWith(isLoading: false, products: products);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateProduct(String id, Product product) async {
  state = state.copyWith(isLoading: true, error: null);

  try {
    final auth = ref.read(authNotifierProvider);
    final token = auth.token ?? ""; // ✅ GET TOKEN
    
    await ref.read(productRepositoryProvider).updateProduct(id, product, token);
    state = state.copyWith(isLoading: false, success: true);
  } catch (e) {
    state = state.copyWith(isLoading: false, error: e.toString());
  }
}

Future<void> deleteProduct(String id) async {
  state = state.copyWith(isLoading: true, error: null);

  try {
    final auth = ref.read(authNotifierProvider);
    final token = auth.token ?? ""; // ✅ GET TOKEN
    
    await ref.read(productRepositoryProvider).deleteProduct(id, token);
    state = state.copyWith(isLoading: false, success: true);
  } catch (e) {
    state = state.copyWith(isLoading: false, error: e.toString());
  }
}


Future<void> addProductWithImages(Product product, List<Uint8List> images) async {
  state = state.copyWith(isLoading: true);

  final auth = ref.read(authNotifierProvider);
  final token = auth.token ?? "";

  await ref.read(productRepositoryProvider)
      .addProductWithImages(product, images, token);

  state = state.copyWith(isLoading: false, success: true);
}


 

}

final productNotifierProvider =
    NotifierProvider<ProductNotifier, ProductState>(ProductNotifier.new);
