import 'package:shopx/domain/auth/user_model.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

   const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  // 1. 🆕 INITIAL STATE: App just started, no user data yet
  const AuthState.initial()
      : user = null,
        isLoading = false,
        error = null;

       // 2. 🔄 LOADING STATE: Login/Register operation in progress, show spinner
  const AuthState.loading()
      : user = null,
        isLoading = true,
        error = null;

      // 3. ✅ AUTHENTICATED STATE: User successfully logged in, store user data
  const AuthState.authenticated(UserModel user)
      : user = user,
        isLoading = false,
        error = null;


     // 4. ❌ UNAUTHENTICATED STATE: User logged out or not logged in yet
  const AuthState.unauthenticated()
      : user = null,
        isLoading = false,
        error = null;

     // 5. ⚠️ ERROR STATE: Something went wrong, show error message to user
  const AuthState.error(String error)
      : user = null,
        isLoading = false,
        error = error;

              
  // 📊 Copy with method for easy state updates
  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

     // 📋 Equality check for state comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthState &&
        other.user == user &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode => user.hashCode ^ isLoading.hashCode ^ error.hashCode;

  // 🖨️ String representation for debugging
  @override
  String toString() => 'AuthState(user: $user, isLoading: $isLoading, error: $error)';       

}
