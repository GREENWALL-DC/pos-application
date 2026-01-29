import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopx/infrastructure/core/dio_provider.dart';

final salesmanApiProvider = Provider<SalesmanApi>((ref) {
  return SalesmanApi(ref.read(dioProvider));
});

class SalesmanApi {
  final Dio _dio;

  SalesmanApi(this._dio);

  // //   // CREATE → admin registers salesperson
  // Future<Map<String, dynamic>> createSalesman(Map<String, dynamic> data) async {
  //   final res = await _dio.post("auth/register", data: data);
  //   return res.data["user"];
  // }

  
Future<Map<String, dynamic>> createSalesman(Map<String, dynamic> data) async {
  try {
    final res = await _dio.post("auth/register", data: data);
    return res.data["user"];
  } on DioException catch (e) {
    if (e.response?.statusCode == 409) {
      throw Exception("USER_ALREADY_EXISTS");
    }

    throw Exception("UNKNOWN_ERROR");
  }
}



 // GET ALL
  Future<List<dynamic>> getSalesmen() async {
    final res = await _dio.get("users/salespersons");
    return res.data;
  }
// GET BY ID
  Future<Map<String, dynamic>> getSalesmanById(int id) async {
    final res = await _dio.get("users/salespersons/$id");
    return res.data;
  }

   // UPDATE
  Future<Map<String, dynamic>> updateSalesman(int id, Map<String, dynamic> data) async {
    final res = await _dio.put("users/salespersons/$id", data: data);
    return res.data["user"];
  }

 // DELETE
  Future<void> deleteSalesman(int id) async {
    await _dio.delete("users/salespersons/$id");
  }
}
