import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopx/application/auth/auth_notifier.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    // baseUrl: "http://localhost:5000/api/",
  baseUrl: "https://shopx-server-p9ov.onrender.com/api/",
    connectTimeout: Duration(seconds: 20),
    receiveTimeout: Duration(seconds: 20),
    headers: {"Content-Type": "application/json"},
  ));

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = ref.read(authNotifierProvider).token;

  
        if (token != null && token.isNotEmpty) {
          options.headers["Authorization"] = "Bearer $token";
        }

        return handler.next(options);
      },
    ),
  );

  return dio;
});
