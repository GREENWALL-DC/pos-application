
import 'dart:typed_data';

import 'package:shopx/domain/products/product.dart';
import 'package:shopx/infrastructure/products/product_api.dart';

class ProductRepository {
  final ProductApi api;

  ProductRepository(this.api);

  // Add product (admin only)
  // 1️⃣ Create product + upload images (admin)
  Future<void> createProduct(Product product, List<Uint8List> images) async {
    // Step 1: Create product (JSON only)
    final productId = await api.createProduct(product);

    // Step 2: Upload images (optional)
    if (images.isNotEmpty) {
      await api.uploadImages(productId, images);
    }
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


// Update product JSON (admin)
  Future<void> updateProduct(String id, Product product) async {
    final json = product.toJson();
    await api.updateProduct(id, json);
  }


// Delete product (admin)
Future<void> deleteProduct(String id) async {
  await api.deleteProduct(id); 
}





}
