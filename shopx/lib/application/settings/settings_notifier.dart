import 'dart:typed_data';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopx/application/settings/settings_state.dart';
import 'package:shopx/domain/settings/company_settings.dart';
import 'package:shopx/infrastructure/settings/settings_api.dart';
import 'package:shopx/infrastructure/settings/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.read(settingsApiProvider));
});

final settingsNotifierProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    return SettingsState.initial();
  }

  /// 🔐 LOAD SETTINGS ONCE
  Future<void> loadOnce() async {
    if (state.isLoading) return;
    if (state.settings != null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await ref.read(settingsRepositoryProvider).getSettings();

      state = state.copyWith(
        isLoading: false,
        settings: data,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 🔥 NEW: UPLOAD COMPANY LOGO
  Future<String> uploadCompanyLogo(Uint8List bytes) async {
    try {
      final logoUrl = await ref
          .read(settingsRepositoryProvider)
          .uploadCompanyLogo(bytes);

      return logoUrl;
    } catch (e) {
      throw Exception("Logo upload failed: $e");
    }
  }

  /// 💾 SAVE SETTINGS
  Future<void> saveSettings(CompanySettings settings) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final saved = await ref
          .read(settingsRepositoryProvider)
          .saveSettings(settings);

      state = state.copyWith(
        isLoading: false,
        settings: saved,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
