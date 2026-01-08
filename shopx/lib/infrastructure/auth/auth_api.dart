import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopx/infrastructure/core/dio_provider.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.read(dioProvider));
});

class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  Future<Map<String, dynamic>> loginUser(
    String username,
    String password,
  ) async {
    try {
      final res = await _dio.post(
        "auth/login",
        data: {"username": username, "password": password},
      );
      return res.data;
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map && data['code'] != null) {
        throw data['code'];
      }

      throw data?['message'] ?? 'LOGIN_FAILED';
    }
  }

  Future<Map<String, dynamic>> loginAdmin(
    String username,
    String password,
  ) async {
    try {
      final res = await _dio.post(
        "auth/admin/login",
        data: {"username": username, "password": password},
      );
      return res.data;
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map && data['code'] != null) {
        throw data['code'];
      }

      throw data?['message'] ?? 'LOGIN_FAILED';
    }
  }

  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
    String phone,
    String token,
  ) async {
    // ✅ FIX: Added 'data:' parameter - same issue as login endpoint
    final res = await _dio.post(
      "auth/register",
      data: {
        "username": username,
        "email": email,
        "password": password,
        "phone": phone,
        "user_type":
            "admin", // ✅ ADDED: Explicitly set as admin (since only admins register)
      },
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    return res.data;
  }

  Future<Map<String, dynamic>> current(String token) async {
    // ✅ CORRECT: GET request doesn't need 'data:' parameter
    final res = await _dio.get(
      "auth/current",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    return res.data;
  }

  // ✅ NEW: Update user profile - required for your backend's PUT /update endpoint
  Future<Map<String, dynamic>> updateUser(
    String token,
    Map<String, dynamic> userData,
  ) async {
    final res = await _dio.put(
      "auth/update",
      data: userData, // Send updated user data in request body
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    return res.data;
  }

  // ✅ NEW: Delete user account - required for your backend's DELETE /delete endpoint
  Future<Map<String, dynamic>> deleteUser(String token) async {
    final res = await _dio.delete(
      "auth/delete",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    return res.data;
  }

  // ✅ NEW: Send OTP - required for your backend's OTP functionality
  Future<Map<String, dynamic>> sendOTP(String token, String method) async {
    final res = await _dio.post(
      "auth/send-otp",
      data: {"method": method}, // 'sms' or 'email' based on your backend
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    return res.data;
  }

  // ✅ NEW: Verify OTP - required for your backend's OTP verification
  // Future<Map<String, dynamic>> verifyOTP(String token, String otp) async {
  //   final res = await _dio.post(
  //     "auth/verify-otp",
  //     data: {"otp": otp}, // Send the OTP code for verification
  //     options: Options(headers: {"Authorization": "Bearer $token"}),
  //   );
  //   return res.data;
  // }
  Future<Map<String, dynamic>> verifyOTP(String token, String otp) async {
    try {
      final res = await _dio.post(
        "auth/verify-otp",
        data: {"otp": otp},
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return res.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        throw 'INCORRECT_OTP';
      }

      throw 'OTP_VERIFICATION_FAILED';
    }
  }

  // ✅ NEW: Admin functionality - get all users (requires admin privileges)
  Future<Map<String, dynamic>> getAllUsers(String token) async {
    final res = await _dio.get(
      "auth/users",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    return res.data;
  }

  // ✅ FIXED: Login owner returns tempToken, not user data
  Future<Map<String, dynamic>> loginOwner(
    String username,
    String password,
  ) async {
    try {
      final res = await _dio.post(
        "auth/login-owner",
        data: {"username": username, "password": password},
      );
      return res.data;
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map && data['code'] != null) {
        throw data['code'];
      }

      throw data?['message'] ?? 'LOGIN_FAILED';
    }
  }

  // 🔁 REFRESH ACCESS TOKEN
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final res = await _dio.post(
        "auth/refresh-token",
        data: {"refreshToken": refreshToken},
      );

      return res.data; // { accessToken, refreshToken }
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map && data['code'] == 'SESSION_EXPIRED') {
        throw 'SESSION_EXPIRED';
      }

      throw 'SESSION_EXPIRED';
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post("auth/logout", data: {"refreshToken": refreshToken});
    } catch (_) {
      // Ignore failure – logout is user intent
    }
  }
}
