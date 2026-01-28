import 'package:shopx/infrastructure/dashboard/admin_dashboard_api.dart';

class AdminDashboardRepository {
  final AdminDashboardApi api;

  AdminDashboardRepository(this.api);

  Future<Map<String, dynamic>> getDashboardData() async {
    return await api.fetchDashboard();
  }

  Future<List<dynamic>> getSalesChart(String range) async {
  return await api.fetchSalesChart(range);
}

}
