import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:shopx/domain/products/product.dart';

class ProductApi {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://localhost:5000/api",
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 5),
    ),
  );

  // POST → Add Product
  Future<void> addProduct(Map<String, dynamic> data, String token) async {
    await _dio.post(
      "/products",
      data: data,
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
  }

  // GET → Fetch All Products
  Future<List<dynamic>> getProducts() async {
    final response = await _dio.get("/products");
    return response.data; // returns a list of JSON objects
  }

  // GET → Fetch single product by ID
  Future<Map<String, dynamic>> getProductById(String id) async {
    final response = await _dio.get("/products/$id");
    return response.data;
  }









// PUT → Update Product by ID
Future<void> updateProduct(String id, Map<String, dynamic> data, String token) async {
  await _dio.put(
    "/products/$id", 
    data: data,
    options: Options(headers: {"Authorization": "Bearer $token"}), // ✅ ADD
  );
}

// DELETE → Remove Product by ID  
Future<void> deleteProduct(String id, String token) async {
  await _dio.delete(
    "/products/$id",
    options: Options(headers: {"Authorization": "Bearer $token"}), // ✅ ADD
  );
}
















  Future<void> addProductWithImages(
    Product product,
    List<Uint8List> images,
    String token,
) async {
  final formData = FormData();

  // Add fields
  formData.fields.add(MapEntry("name", product.name));
  formData.fields.add(MapEntry("price", product.price.toString()));
  formData.fields.add(MapEntry("category", product.category));
  formData.fields.add(MapEntry("description", product.description));
  formData.fields.add(MapEntry("unit", product.unit));

  // Add images as bytes
  for (int i = 0; i < images.length; i++) {
    formData.files.add(
      MapEntry(
        "images",
        MultipartFile.fromBytes(
          images[i],
          filename: "image_$i.png",
        ),
      ),
    );
  }

  await _dio.post(
    "/products",
    data: formData,
    options: Options(
      headers: {"Authorization": "Bearer $token"},
    ),
  );
}

}

// if (auth.role == "admin") {
//   Navigator.push(context, MaterialPageRoute(builder: (_) => AddProductPage()));
// }
