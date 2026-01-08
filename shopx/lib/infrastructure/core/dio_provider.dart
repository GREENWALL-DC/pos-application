import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopx/application/auth/auth_notifier.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      // baseUrl: "http://localhost:5000/api/",
      // baseUrl: "https://shopx-server-p9ov.onrender.com/api/",this is render
      //  baseUrl: "https://aba65707ae3f.ngrok-free.app/api/",
      baseUrl: "http://16.112.120.235:5000/api/", // Aws

      connectTimeout: Duration(seconds: 20),
      receiveTimeout: Duration(seconds: 20),
      headers: {
        "Content-Type": "application/json",
        //  "ngrok-skip-browser-warning": "true",
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      // onRequest: (options, handler) {
      //   final token = ref.read(authNotifierProvider).token;

      //   if (token != null && token.isNotEmpty) {
      //     options.headers["Authorization"] = "Bearer $token";
      //   }

      //   return handler.next(options);
      // },
      onRequest: (options, handler) {
        // 🔥 DO NOTHING HERE
        // Authorization is handled explicitly per API call
        return handler.next(options);
      },
    ),
  );

  return dio;
});
