import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopx/application/auth/auth_notifier.dart';
import 'package:shopx/application/auth/auth_state.dart';
import 'package:shopx/application/connectivity/connectivity_provider.dart';

enum AppBootstrapState {
  loading,
  offline,
  ready,
}

final appBootstrapProvider = Provider<AppBootstrapState>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  final authState = ref.watch(authNotifierProvider);

  return connectivity.when(
    loading: () => AppBootstrapState.loading,
    error: (_, __) => AppBootstrapState.offline,
    data: (isOnline) {
      // 🔴 Internet OFF → always offline screen
      if (!isOnline) {
        return AppBootstrapState.offline;
      }

      // 🔑 Internet ON but auth not yet reloaded
      if (!authState.isAuthenticated && !authState.isInitializing) {
        ref.read(authNotifierProvider.notifier).retryAuth();
        return AppBootstrapState.loading;
      }

      // ⏳ Auth still initializing
      if (authState.isInitializing) {
        return AppBootstrapState.loading;
      }

      // ✅ Everything ready
      return AppBootstrapState.ready;
    },
  );
});
