import 'package:shopx/domain/settings/company_settings.dart';
import 'package:shopx/infrastructure/settings/settings_api.dart';

class SettingsRepository {
  final SettingsApi api;

  SettingsRepository(this.api);

  Future<CompanySettings?> getSettings() async {
    final json = await api.getSettings();
    if (json.isEmpty) return null;
    return CompanySettings.fromJson(json);
  }

  Future<CompanySettings> saveSettings(CompanySettings settings) async {
    final res = await api.saveSettings(settings.toJson());
    return CompanySettings.fromJson(res);
  }
}
