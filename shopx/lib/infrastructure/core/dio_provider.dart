import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopx/application/auth/auth_notifier.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      // baseUrl: "http://localhost:5000/api/",
      // baseUrl: "https://shopx-server-p9ov.onrender.com/api/",this is render
      //  baseUrl: "https://aba65707ae3f.ngrok-free.app/api/",
      // baseUrl: "http://16.112.120.235:5000/api/", // Aws
      baseUrl: "http://sellops.cloud:5000/api/",

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
    onRequest: (options, handler) {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      final token = authNotifier.accessToken;

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      return handler.next(options);
    },
    onError: (error, handler) {
      // Optional: helpful debug
      // print('Dio error: ${error.response?.statusCode}');
      return handler.next(error);
    },
  ),
);




// bool isRefreshing = false;
// final List<Future<void> Function()> retryQueue = [];


// dio.interceptors.add(
//   InterceptorsWrapper(
//     onRequest: (options, handler) {
//       final authNotifier = ref.read(authNotifierProvider.notifier);
//       final token = authNotifier.accessToken;

//       if (token != null && token.isNotEmpty) {
//         options.headers['Authorization'] = 'Bearer $token';
//       }

//       handler.next(options);
//     },

//     onError: (error, handler) async {
//       final response = error.response;
//       final authNotifier = ref.read(authNotifierProvider.notifier);

//       // Only handle 401
//       if (response?.statusCode == 401 &&
//           authNotifier.hasLocalSession) {

//         // Queue retry
//         final completer = Completer<Response>();
//         retryQueue.add(() async {
//           try {
//             final newToken = authNotifier.accessToken;
//             error.requestOptions.headers['Authorization'] =
//                 'Bearer $newToken';

//             final retryResponse =
//                 await dio.fetch(error.requestOptions);
//             completer.complete(retryResponse);
//           } catch (e) {
//             completer.completeError(e);
//           }
//         });

//         // Start refresh only once
//         if (!isRefreshing) {
//           isRefreshing = true;

//           try {
//             await authNotifier.retryAuth();

//             for (final retry in retryQueue) {
//               await retry();
//             }
//           } catch (_) {
//             // AuthNotifier already handles logout
//           } finally {
//             retryQueue.clear();
//             isRefreshing = false;
//           }
//         }

//         return handler.resolve(await completer.future);
//       }

//       // Not a 401 → pass through
//       handler.next(error);
//     },
//   ),
// );




  return dio;
});
