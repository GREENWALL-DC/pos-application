import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopx/infrastructure/auth/auth_repositary.dart';
import 'auth_state.dart';

// 🎯 AUTH NOTIFIER: Manages authentication state and business logic
class AuthNotifier extends Notifier<AuthState> {
  String? _tempToken;
  String? _selectedOtpMethod; // ✅ ADD: Store selected method

  @override
  AuthState build() {
    // ✅ STEP 2: ADD this new method (replaces constructor)
    return const AuthState.initial();
  }

  // 🔐 LOGIN: Authenticate user with username and password
  Future<void> login(String username, String password) async {
    state = const AuthState.loading();

    try {
      final user = await ref
          .read(authRepositoryProvider)
          .login(username, password);
      state = AuthState.authenticated(user);
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
      final user = await ref
          .read(authRepositoryProvider)
          .register(username, email, password, phone, adminToken);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  // 🔍 GET CURRENT USER: Fetch current logged-in user
  Future<void> getCurrentUser(String token) async {
    state = const AuthState.loading();

    try {
      final user = await ref.read(authRepositoryProvider).getCurrentUser(token);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
      // If getting current user fails, assume user is not authenticated
      await logout();
    }
  }

  // 🚪 LOGOUT: Clear user data and return to unauthenticated state
  Future<void> logout() async {
    state = const AuthState.unauthenticated();

    // Here you can also clear stored tokens from secure storage
    // await _secureStorage.deleteToken();
  }

  // ✏️ UPDATE PROFILE: Update user information
  Future<void> updateProfile(
    String token,
    Map<String, dynamic> userData,
  ) async {
    state = state.copyWith(isLoading: true);

    try {
      final updatedUser = await ref
          .read(authRepositoryProvider)
          .updateUser(token, userData);
      state = AuthState.authenticated(updatedUser);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 🗑️ DELETE ACCOUNT: Delete current user's account
  Future<void> deleteAccount(String token) async {
    state = const AuthState.loading();

    try {
      await ref.read(authRepositoryProvider).deleteUser(token);
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
  Future<void> verifyOTP(String otp) async {
    if (_tempToken == null) {
      state = AuthState.error("Session expired. Please login again");
      return;
    }

    state = const AuthState.loading();

    try {
      final user = await ref
          .read(authRepositoryProvider)
          .verifyOTP(_tempToken!, otp);
      _tempToken = null; // Clear temp token after success
      _selectedOtpMethod = null; // Clear method after success
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
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
