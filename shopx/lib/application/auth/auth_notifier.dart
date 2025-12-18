import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopx/domain/auth/user_model.dart';
import 'package:shopx/infrastructure/auth/auth_repositary.dart';
import 'auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🎯 AUTH NOTIFIER: Manages authentication state and business logic
class AuthNotifier extends Notifier<AuthState> {
  String? _tempToken;
  String? _selectedOtpMethod; // ✅ ADD: Store selected method
  String? _jwtToken; // ✅ ADD THIS: Store permanent JWT token

  @override
  AuthState build() {
    // Start with loading state until we verify stored token
     _initAuth();   // 🔥 auto check stored token
    return const AuthState.unauthenticated();
  }

  Future<void> _initAuth() async {
    final storedToken = await _loadToken();

    if (storedToken == null) {
      state = const AuthState.unauthenticated();
      return;
    }

    try {
      final user = await ref
          .read(authRepositoryProvider)
          .getCurrentUser(storedToken);

      _jwtToken = storedToken; // restore token to memory
      state = AuthState.authenticated(user, token: storedToken);
    } catch (_) {
      await logout();
    }
  }

  // 🔥 LOCAL TOKEN STORAGE (SharedPreferences)
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("jwt_token", token);
  }

  Future<String?> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt_token");
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("jwt_token");
  }

  // 🔐 LOGIN: Authenticate user with username and password
  Future<void> loginUser(String username, String password) async {
    state = const AuthState.loading();

    try {
      final result = await ref
          .read(authRepositoryProvider)
          .loginUser(username, password);

      final user = result['user'] as UserModel;
      final token = result['token'] as String;

      _jwtToken = token;
      await _saveToken(token);

      state = AuthState.authenticated(user, token: token);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> loginAdmin(String username, String password) async {
    state = const AuthState.loading();

    try {
      final result = await ref
          .read(authRepositoryProvider)
          .loginAdmin(username, password);

      final user = result['user'] as UserModel;
      final token = result['token'] as String;

      _jwtToken = token;
      await _saveToken(token);

      state = AuthState.authenticated(user, token: token);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  // 👤 REGISTER: Create new admin user (admin-only)
  Future<void> register(
    String username,
    String email,
    String password,
    String phone,
    String adminToken,
  ) async {
    state = const AuthState.loading();

    try {
      // ✅ UPDATED: Get result with both user and token
      final result = await ref
          .read(authRepositoryProvider)
          .register(username, email, password, phone, adminToken);

      final user = result['user'] as UserModel;
      final token = result['token'] as String;

      // ✅ Store the token
      _jwtToken = token;
      await _saveToken(token);
      state = AuthState.authenticated(user, token: token);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> getCurrentUser() async {
    // ✅ REMOVED token parameter
    if (_jwtToken == null) {
      // ✅ Check if we have a token
      state = const AuthState.unauthenticated();
      return;
    }

    state = const AuthState.loading();

    try {
      final user = await ref
          .read(authRepositoryProvider)
          .getCurrentUser(_jwtToken!);
      state = AuthState.authenticated(user, token: _jwtToken); // ✅ Pass token
    } catch (e) {
      state = AuthState.error(e.toString());
      await logout();
    }
  }

  // 🚪 LOGOUT: Clear user data and return to unauthenticated state
  Future<void> logout() async {
    // ✅ Clear ALL tokens
    _jwtToken = null;
    _tempToken = null;
    _selectedOtpMethod = null;
    await _clearToken(); // 🔥 delete token locally
    state = const AuthState.unauthenticated();

    // Here you can also clear stored tokens from secure storage
    // await _secureStorage.deleteToken();
  }

  Future<void> updateProfile(
    Map<String, dynamic> userData, // ✅ REMOVED token parameter
  ) async {
    if (_jwtToken == null) {
      state = AuthState.error("Not authenticated");
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final updatedUser = await ref
          .read(authRepositoryProvider)
          .updateUser(_jwtToken!, userData); // ✅ Use stored token
      state = AuthState.authenticated(
        updatedUser,
        token: _jwtToken,
      ); // ✅ Keep token
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteAccount() async {
    // ✅ REMOVED token parameter
    if (_jwtToken == null) {
      state = AuthState.error("Not authenticated");
      return;
    }

    state = const AuthState.loading();

    try {
      await ref
          .read(authRepositoryProvider)
          .deleteUser(_jwtToken!); // ✅ Use stored token
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  // 🔑 STEP 1: Login owner and get TEMP token
  Future<void> loginOwner(String username, String password) async {
    state = const AuthState.loading();

    try {
      _tempToken = await ref
          .read(authRepositoryProvider)
          .loginOwner(username, password);
      state = const AuthState.unauthenticated(); // Not authenticated yet
      // state = const AuthState.initial();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  // 📱 STEP 2: Send OTP via any method (Email, WhatsApp, SMS, Missed Call)
  Future<void> sendOTP(String method) async {
    if (_tempToken == null) {
      state = AuthState.error("Please login first");
      return;
    }

    _selectedOtpMethod = method; // ✅ Store the method being used
    state = state.copyWith(isLoading: true);

    try {
      await ref.read(authRepositoryProvider).sendOTP(_tempToken!, method);
      state = state.copyWith(isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ✅ STEP 3: Verify OTP (works for ALL methods)
  // Future<void> verifyOTP(String otp) async {
  //   if (_tempToken == null) {
  //     state = AuthState.error("Session expired. Please login again");
  //     return;
  //   }

  //   state = const AuthState.loading();

  //   try {
  //     // ✅ FIX: Get BOTH user AND token
  //     final result = await ref
  //         .read(authRepositoryProvider)
  //         .verifyOTP(_tempToken!, otp);

  //     // ✅ Extract both values from result
  //     final user = result['user'] as UserModel;
  //     final permanentToken = result['token'] as String;

  //     // ✅ Store the permanent token
  //     _jwtToken = permanentToken;
  //     _tempToken = null; // Clear temp token after success
  //     _selectedOtpMethod = null; // Clear method after success
  //     await _saveToken(permanentToken); // 🔥 save token
  //     state = AuthState.authenticated(user, token: permanentToken);
  //   } catch (e) {
  //     state = AuthState.error(e.toString());
  //   }
  // }
  Future<bool> verifyOTP(String otp) async {
    if (_tempToken == null) {
      state = AuthState.error("Session expired. Please login again");
      return false;
    }

    state = const AuthState.loading();

    try {
      final result = await ref
          .read(authRepositoryProvider)
          .verifyOTP(_tempToken!, otp);

      // ✅ CORRECT OTP
      final user = result['user'] as UserModel;
      final permanentToken = result['token'] as String;

      _jwtToken = permanentToken;
      _tempToken = null;
      _selectedOtpMethod = null;
      await _saveToken(permanentToken);

      state = AuthState.authenticated(user, token: permanentToken);
      return true;
    } catch (e) {
      // ❌ WRONG OTP or server error
      state = AuthState.error("Incorrect OTP");
      return false;
    }
  }

  // 🧹 CLEAR ERROR: Clear any error message
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}

// 🎯 PROVIDER: Makes AuthNotifier available throughout the app
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
