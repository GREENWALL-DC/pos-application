import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopx/infrastructure/core/dio_provider.dart';

final adminDashboardApiProvider = Provider<AdminDashboardApi>((ref) {
  return AdminDashboardApi(ref.read(dioProvider));
});

class AdminDashboardApi {
  final Dio _dio;

  AdminDashboardApi(this._dio);

  Future<Map<String, dynamic>> fetchDashboard() async {
    final res = await _dio.get("/dashboard");
    return res.data;
  }

  Future<List<dynamic>> fetchSalesChart(String range) async {
  final res = await _dio.get(
    "/dashboard/sales-chart",
    queryParameters: {"range": range},
  );
  return res.data;
}

}
