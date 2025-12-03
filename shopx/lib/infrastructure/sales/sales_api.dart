import 'package:dio/dio.dart';

class SalesApi {
  final Dio _dio;

  SalesApi(this._dio);

  Future<Map<String, dynamic>> createSale(Map<String, dynamic> data) async {
    final res = await _dio.post("/sales", data: data);
    return res.data;
  }

  Future<Map<String, dynamic>> getSaleById(int id) async {
    final res = await _dio.get("/sales/$id");
    return res.data;
  }

  Future<List<dynamic>> getAllSales() async {
    final res = await _dio.get("/sales");
    return res.data;
  }
}
