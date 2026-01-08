import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopx/application/auth/auth_notifier.dart';
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
      // 🚫 Internet OFF → show offline screen
      if (!isOnline) {
        return AppBootstrapState.offline;
      }

      // ⏳ Auth is still initializing → splash
      if (authState.isInitializing) {
        return AppBootstrapState.loading;
      }

      // ✅ Internet ON + auth resolved (authenticated OR unauthenticated)
      return AppBootstrapState.ready;
    },
  );
});
