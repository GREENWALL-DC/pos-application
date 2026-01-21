import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopx/application/settings/settings_state.dart';
import 'package:shopx/domain/settings/company_settings.dart';
import 'package:shopx/infrastructure/settings/settings_api.dart';
import 'package:shopx/infrastructure/settings/settings_repository.dart';

// Repository Provider (centralized style)
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.read(settingsApiProvider));
});

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    return SettingsState();
  }

  // LOAD SETTINGS
  Future<void> fetchSettings() async {
    state = state.copyWith(isLoading: true, error: null, success: false);

    try {
      final data = await ref.read(settingsRepositoryProvider).getSettings();

      if (data == null) {
        throw Exception("Company settings not found");
      }

      state = state.copyWith(isLoading: false, settings: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // SAVE SETTINGS
  Future<void> saveSettings(CompanySettings settings) async {
    state = state.copyWith(isLoading: true, error: null, success: false);

    try {
      final saved = await ref
          .read(settingsRepositoryProvider)
          .saveSettings(settings);
      state = state.copyWith(isLoading: false, success: true, settings: saved);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final settingsNotifierProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
