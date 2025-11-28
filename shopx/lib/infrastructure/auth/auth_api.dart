import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(
    Dio(
      BaseOptions(
        baseUrl: "http://localhost:5000/api/auth",
        connectTimeout: Duration(seconds: 5),
        receiveTimeout: Duration(seconds: 5),
      ),
    ),
  );
});

class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final res = await _dio.post(
        "/login",
        data: {"username": username, "password": password},
      );
      return res.data;
    } on DioException catch (e) {
      throw e.response?.data?['message'] ?? 'Login failed';
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
      "/register",
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
      "/current",
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
      "/update",
      data: userData, // Send updated user data in request body
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    return res.data;
  }

  // ✅ NEW: Delete user account - required for your backend's DELETE /delete endpoint
  Future<Map<String, dynamic>> deleteUser(String token) async {
    final res = await _dio.delete(
      "/delete",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    return res.data;
  }

  // ✅ NEW: Send OTP - required for your backend's OTP functionality
  Future<Map<String, dynamic>> sendOTP(String token, String method) async {
    final res = await _dio.post(
      "/send-otp",
      data: {"method": method}, // 'sms' or 'email' based on your backend
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    return res.data;
  }

  // ✅ NEW: Verify OTP - required for your backend's OTP verification
  Future<Map<String, dynamic>> verifyOTP(String token, String otp) async {
    final res = await _dio.post(
      "/verify-otp",
      data: {"otp": otp}, // Send the OTP code for verification
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    return res.data;
  }

  // ✅ NEW: Admin functionality - get all users (requires admin privileges)
  Future<Map<String, dynamic>> getAllUsers(String token) async {
    final res = await _dio.get(
      "/users",
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
        "/login-owner",
        data: {"username": username, "password": password},
      );
      return res.data;
    } on DioException catch (e) {
      throw e.response?.data?['message'] ?? 'Admin login failed';
    }
  }
}
