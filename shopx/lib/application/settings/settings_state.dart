import 'package:shopx/domain/settings/company_settings.dart';

class SettingsState {
  final bool isLoading;
  final String? error;
  final CompanySettings? settings;

  const SettingsState({
    this.isLoading = false,
    this.error,
    this.settings,
  });

  factory SettingsState.initial() {
  return const SettingsState(
    isLoading: false,
    settings: null,
    error: null,
  );
}


  SettingsState copyWith({
    bool? isLoading,
    String? error,
    CompanySettings? settings,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      settings: settings ?? this.settings,
    );
  }
}
