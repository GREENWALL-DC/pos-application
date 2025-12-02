import 'dart:io';
import 'dart:typed_data';

import 'package:shopx/domain/products/product.dart';
import 'package:shopx/infrastructure/products/product_api.dart';

class ProductRepository {
  final ProductApi api;

  ProductRepository(this.api);

  // Add product (admin only)
  Future<void> addProduct(Product product, String token) async {
  final json = product.toJson();
  await api.addProduct(json, token);
}


    // Fetch all products (public)
  Future<List<Product>> getProducts() async {
    final response = await api.getProducts();
    return response
        .map<Product>((json) => Product.fromJson(json))
        .toList();
  }

  // Fetch single product (public)
  Future<Product> getProductById(String id) async {
    final json = await api.getProductById(id);
    return Product.fromJson(json);
  }


// Update a product (admin)
Future<void> updateProduct(String id, Product product, String token) async {
  final json = product.toJson();
  await api.updateProduct(id, json, token); // ✅ ADD token
}

// Delete product (admin)
Future<void> deleteProduct(String id, String token) async {
  await api.deleteProduct(id, token); // ✅ ADD token
}

Future<void> addProductWithImages(
  Product product,
  List<Uint8List> images,
  String token,
) async {
  await api.addProductWithImages(product, images, token);
}



}
