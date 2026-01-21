import 'package:shopx/domain/settings/company_settings.dart';

class SettingsState {
  final bool isLoading;
  final String? error;
  final bool success;
  final CompanySettings? settings;

  SettingsState({
    this.isLoading = false,
    this.error,
    this.success = false,
    this.settings,
  });

  SettingsState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
    CompanySettings? settings,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
      settings: settings ?? this.settings,
    );
  }
}
