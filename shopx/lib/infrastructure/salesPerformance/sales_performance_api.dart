import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopx/infrastructure/core/dio_provider.dart';

final salesPerformanceApiProvider = Provider<SalesPerformanceApi>((ref) {
  return SalesPerformanceApi(ref.read(dioProvider));
});

class SalesPerformanceApi {
  final Dio _dio;

  SalesPerformanceApi(this._dio);

  /// Summary Overview API
  Future<Map<String, dynamic>> getSummary(String start, String end) async {
    final response = await _dio.get(
      "/reports/summary",
      queryParameters: {"start": start, "end": end},
    );
    return response.data;
  }

  /// Salesman Performance API
  Future<List<dynamic>> getSalesmanPerformance(String start, String end) async {
    final response = await _dio.get(
      "/reports/salesman",
      queryParameters: {"start": start, "end": end},
    );
    return response.data;
  }

  /// Product Sales API
  Future<List<dynamic>> getProductSales(String start, String end) async {
    final response = await _dio.get(
      "/reports/products",
      queryParameters: {"start": start, "end": end},
    );
    return response.data;
  }

//customer 
  Future<List<dynamic>> getCustomerPerformance(String start, String end) async {
  final response = await _dio.get(
    "/reports/customers",
    queryParameters: {"start": start, "end": end},
  );
  return response.data;
}

}
