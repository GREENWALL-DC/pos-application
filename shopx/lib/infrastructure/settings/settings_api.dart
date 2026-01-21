import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopx/infrastructure/core/dio_provider.dart';

final settingsApiProvider = Provider<SettingsApi>((ref) {
  return SettingsApi(ref.read(dioProvider));
});

class SettingsApi {
  final Dio _dio;

  SettingsApi(this._dio);

  // GET settings
  Future<Map<String, dynamic>> getSettings() async {
    final res = await _dio.get('/company-settings');
    return res.data;
  }

  // CREATE / UPDATE settings
  Future<Map<String, dynamic>> saveSettings(Map<String, dynamic> data) async {
    final res = await _dio.post('/company-settings', data: data);
    return res.data['data'];
  }
}
