import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopx/application/connectivity/connectivity_provider.dart';

enum AppBootstrapState {
  offline,
  ready,
}

final appBootstrapProvider = Provider<AppBootstrapState>((ref) {
  final connectivity = ref.watch(connectivityProvider);

  return connectivity.when(
    loading: () => AppBootstrapState.ready, // ⛔ NEVER splash here
    error: (_, __) => AppBootstrapState.offline,
    data: (isOnline) {
      return isOnline
          ? AppBootstrapState.ready
          : AppBootstrapState.offline;
    },
  );
});
