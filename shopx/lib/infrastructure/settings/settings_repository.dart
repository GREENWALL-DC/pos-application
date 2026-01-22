import 'dart:typed_data';
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

 /// 🔥 UPLOAD COMPANY LOGO (MULTIPART)
Future<String> uploadCompanyLogo(Uint8List bytes) async {
  final res = await api.uploadCompanyLogo(bytes);

  final relativePath = res['logoUrl'] as String;

  // 🔑 Convert to FULL URL (same idea as product images)
  final baseUrl = api.dio.options.baseUrl.replaceAll('/api/', '');

  return '$baseUrl$relativePath';
}


  /// 💾 SAVE SETTINGS
  Future<CompanySettings> saveSettings(CompanySettings settings) async {
    final payload = {
      "companyNameEn": settings.companyNameEn,
      "companyNameAr": settings.companyNameAr,
      "companyAddressEn": settings.companyAddressEn,
      "companyAddressAr": settings.companyAddressAr,
      "vatNumber": settings.vatNumber,
      "crNumber": settings.crNumber,
      "phone": settings.phone,
      "email": settings.email,
      "accountNumber": settings.accountNumber,
      "iban": settings.iban,
      "logoUrl": settings.logoUrl,
    };

    final res = await api.saveSettings(payload);
    return CompanySettings.fromJson(res);
  }
}
