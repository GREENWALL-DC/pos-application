import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopx/application/dashboard/admin_dashboard_state.dart';
import 'package:shopx/infrastructure/dashboard/admin_dashboard_api.dart';
import 'package:shopx/infrastructure/dashboard/admin_dashboard_repository.dart';

final adminDashboardRepositoryProvider = Provider<AdminDashboardRepository>((
  ref,
) {
  return AdminDashboardRepository(ref.read(adminDashboardApiProvider));
});

final adminDashboardNotifierProvider =
    NotifierProvider<AdminDashboardNotifier, AdminDashboardState>(
      AdminDashboardNotifier.new,
    );

class AdminDashboardNotifier extends Notifier<AdminDashboardState> {
  // 🔥 STRICT PARSER — Add this
  num parseRequired(dynamic value, String fieldName) {
    final parsed = num.tryParse(value.toString());
    if (parsed == null) {
      throw Exception(
        "Invalid numeric value for $fieldName → Received: $value",
      );
    }
    return parsed;
  }

  bool _loaded = false;

  @override
  AdminDashboardState build() {
    if (!_loaded) {
      Future.microtask(loadDashboard);
      _loaded = true;
    }
    return AdminDashboardState.initial();
  }

  Future<void> loadDashboard() async {
    state = state.copyWith(loading: true, error: null);

    try {
      final repo = ref.read(adminDashboardRepositoryProvider);
      final data = await repo.getDashboardData();

      final totalsJson = data['totals'] ?? {};
      final charts = data['charts'] ?? {};
      final tables = data['tables'] ?? {};

      state = state.copyWith(
        loading: false,

        // ✅ CORRECT TOTALS PARSING
        totals: Totals.fromJson(totalsJson),

        // ✅ GLOBAL METRICS
        totalCustomers: parseRequired(
          totalsJson['total_customers'],
          'total_customers',
        ),
        totalDiscount: parseRequired(
          totalsJson['total_discount'],
          'total_discount',
        ),

        // ✅ CHARTS
        weeklySummary: (charts['weekly_summary'] ?? [])
            .map<Map<String, dynamic>>(
              (row) => {
                'day': row['day'],
                'revenue': parseRequired(row['revenue'], 'weekly.revenue'),
                'transactions': parseRequired(
                  row['transactions'],
                  'weekly.transactions',
                ),
              },
            )
            .toList(),

        topProducts: (charts['top_products'] ?? [])
            .map<Map<String, dynamic>>(
              (row) => {
                'name': row['name'],
                'total_qty': parseRequired(
                  row['total_qty'],
                  'top_products.qty',
                ),
              },
            )
            .toList(),

        salesBySalesperson: List<Map<String, dynamic>>.from(
          charts['sales_by_salesperson'] ?? [],
        ),

        // ✅ TABLES
        recentSales: (tables['recent_sales'] ?? [])
            .map<Map<String, dynamic>>(
              (row) => {
                'id': row['id'],
                'customer': row['customer'],
                'sale_date': row['sale_date'],
                'total_amount': parseRequired(
                  row['total_amount'],
                  'recent.amount',
                ),
                'sale_status': row['sale_status'],
                'payment_status': row['payment_status'],
              },
            )
            .toList(),

        lowStock: List<Map<String, dynamic>>.from(tables['low_stock'] ?? []),
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> fetchDashboard() async {
    await loadDashboard();
  }
}
