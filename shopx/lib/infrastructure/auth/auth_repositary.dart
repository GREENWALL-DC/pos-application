import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopx/domain/auth/user_model.dart';
import 'package:shopx/infrastructure/auth/auth_api.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(authApiProvider));
});

class AuthRepository {
  final AuthApi _api;

  AuthRepository(this._api);

  // 🔐 LOGIN: Authenticate user and get user data
  Future<UserModel> login(String username, String password) async {
    try {
      final response = await _api.login(username, password);
      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Login repository failed: $e');
    }
  }

  // 👤 REGISTER: Create new admin user (admin-only operation)
  Future<UserModel> register(
    String username,
    String email,
    String password,
    String phone,
    String adminToken,
  ) async {
    final response = await _api.register(
      username,
      email,
      password,
      phone,
      adminToken,
    );
    final userJson = response["user"];
    return UserModel.fromJson(userJson);
  }

  // 🔍 GET CURRENT USER: Fetch logged-in user's profile
  Future<UserModel> getCurrentUser(String token) async {
    // 📤 Send request to get current user profile
    final response = await _api.current(token);

    // 🎯 Your UserModel.fromJson can handle: { "id": 1, "username": "...", ... }
    return UserModel.fromJson(response);
  }

  // ✏️ UPDATE USER: Update user profile information
  Future<UserModel> updateUser(
    String token,
    Map<String, dynamic> userData,
  ) async {
    final response = await _api.updateUser(token, userData);
    // Response: { "message": "...", "user": { ... } } or direct user object
    final userJson = response["user"] ?? response;
    return UserModel.fromJson(userJson);
  }

  // 🗑️ DELETE USER: Delete current user's account
  Future<void> deleteUser(String token) async {
    await _api.deleteUser(token);
    // No return needed - just confirmation it succeeded
  }

  // 📱 SEND OTP: Send OTP for verification (SMS/Email)
  Future<void> sendOTP(String token, String method) async {
    await _api.sendOTP(token, method);
    // No return needed - just confirmation it succeeded
  }

  // ✅ VERIFY OTP: Verify OTP code and get user data
  Future<UserModel> verifyOTP(String token, String otp) async {
    final response = await _api.verifyOTP(token, otp);
  final userJson = response["user"];
      return UserModel.fromJson(response);
  }

  // 👥 GET ALL USERS: Admin-only - get list of all users
  Future<List<UserModel>> getAllUsers(String token) async {
    final response = await _api.getAllUsers(token);
    // Response: { "message": "...", "users": [...] }
    final usersList = response["users"] as List;
    return usersList.map((userJson) => UserModel.fromJson(userJson)).toList();
  }

  // 🔑 LOGIN OWNER: Special login for admin/owner
  Future<String> loginOwner(String username, String password) async {
    final response = await _api.loginOwner(username, password);
    // Response: { "tempToken": "..." } - we need to return just the token

    return response["tempToken"] as String;
  }
}
