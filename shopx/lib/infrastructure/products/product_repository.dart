
import 'dart:typed_data';

import 'package:shopx/domain/products/product.dart';
import 'package:shopx/infrastructure/products/product_api.dart';

class ProductRepository {
  final ProductApi api;

  ProductRepository(this.api);

  // Add product (admin only)
  // 1️⃣ Create product + upload images (admin)
  // CREATE PRODUCT → return newly created Product
Future<Product> createProduct(Product product, List<Uint8List> images) async {
  // 1️⃣ Create product (backend returns productId)
  final productId = await api.createProduct(product);

  List<String> uploadedUrls = [];

  // 2️⃣ Upload images (optional)
  if (images.isNotEmpty) {
    await api.uploadImages(productId, images);
  }

  // 3️⃣ Build final product object for instant UI update
  return Product(
    id: productId.toString(),
    name: product.name,
    price: product.price,
    category: product.category,
    quantity: product.quantity,
    code: product.code,
    vat: product.vat,
    images: uploadedUrls,
  );
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
Future<Product> updateProduct(
  String id,
  Product product,
  List<String> existingUrls,
  List<Uint8List> newImages,
) async {
  // 1️⃣ Update core product fields
  await api.updateProduct(id, product.toJson());

  // 2️⃣ Upload new images
  List<String> newUrls = [];
  if (newImages.isNotEmpty) {
    await api.uploadImages(int.parse(id), newImages);
  }

  // 3️⃣ Return updated Product for UI
  return Product(
    id: id,
    name: product.name,
    price: product.price,
    category: product.category,
    quantity: product.quantity,
    code: product.code,
    vat: product.vat,
    images: [
      ...existingUrls, // keep old
      ...newUrls,      // add new
    ],
  );
}




// Delete product (admin)
Future<void> deleteProduct(String id) async {
  await api.deleteProduct(id); 
}





}
