class RevenueMetrics {
  final num revenue;
  final int totalSales;
  final num avgOrderValue;

  const RevenueMetrics({
    required this.revenue,
    required this.totalSales,
    required this.avgOrderValue,
  });

  factory RevenueMetrics.fromJson(Map<String, dynamic> json) {
    return RevenueMetrics(
      revenue: json['revenue'] ?? 0,
      totalSales: json['total_sales'] ?? 0,
      avgOrderValue: json['avg_order_value'] ?? 0,
    );
  }
}

class Totals {
  final RevenueMetrics all;
  final RevenueMetrics today;

  const Totals({required this.all, required this.today});

  factory Totals.fromJson(Map<String, dynamic> json) {
    return Totals(
      all: RevenueMetrics.fromJson(json['all'] ?? {}),
      today: RevenueMetrics.fromJson(json['today'] ?? {}),
    );
  }
}

class AdminDashboardState {
  final bool loading;
  final String? error;

  // // totals
  // final num grossRevenue;     // NEW
  // final num totalSales;       // KEEP (order count)
  // final num totalPayments;
  // final num pendingAmount;
  // final num todaySales;
  // final num netSales;         // NEW

  final Totals totals;

  final num totalCustomers;
  final num totalDiscount; // NEW

  // charts
  final List<Map<String, dynamic>> weeklySummary;
  final List<Map<String, dynamic>> topProducts;
  final List<Map<String, dynamic>> salesBySalesperson;

  // tables
  final List<Map<String, dynamic>> recentSales;
  final List<Map<String, dynamic>> lowStock;

  const AdminDashboardState({
    this.loading = false,
    this.error,

    //    this.grossRevenue = 0,      // NEW
    // this.totalSales = 0,        // KEEP
    // this.totalPayments = 0,
    // this.pendingAmount = 0,
    // this.todaySales = 0,
    // this.netSales = 0,          // NEW
    required this.totals,
    this.totalCustomers = 0,
    this.totalDiscount = 0, // NEW

    this.weeklySummary = const [],
    this.topProducts = const [],
    this.salesBySalesperson = const [],

    this.recentSales = const [],
    this.lowStock = const [],
  });

  AdminDashboardState copyWith({
    bool? loading,
    String? error,

    //   num? grossRevenue,       // NEW
    // num? totalSales,         // KEEP
    // num? totalPayments,
    // num? pendingAmount,
    // num? todaySales,
    // num? netSales,           // NEW
    Totals? totals,
    num? totalCustomers,
    num? totalDiscount, // NEW

    List<Map<String, dynamic>>? weeklySummary,
    List<Map<String, dynamic>>? topProducts,
    List<Map<String, dynamic>>? salesBySalesperson,

    List<Map<String, dynamic>>? recentSales,
    List<Map<String, dynamic>>? lowStock,
  }) {
    return AdminDashboardState(
      loading: loading ?? this.loading,
      error: error,

      // grossRevenue: grossRevenue ?? this.grossRevenue,
      // totalSales: totalSales ?? this.totalSales,
      // totalPayments: totalPayments ?? this.totalPayments,
      // pendingAmount: pendingAmount ?? this.pendingAmount,
      // todaySales: todaySales ?? this.todaySales,
      // netSales: netSales ?? this.netSales,
      totals: totals ?? this.totals,

      totalCustomers: totalCustomers ?? this.totalCustomers,
      totalDiscount: totalDiscount ?? this.totalDiscount,

      weeklySummary: weeklySummary ?? this.weeklySummary,
      topProducts: topProducts ?? this.topProducts,
      salesBySalesperson: salesBySalesperson ?? this.salesBySalesperson,

      recentSales: recentSales ?? this.recentSales,
      lowStock: lowStock ?? this.lowStock,
    );
  }

  factory AdminDashboardState.initial() {
    return AdminDashboardState(
      totals: Totals(
        all: RevenueMetrics(revenue: 0, totalSales: 0, avgOrderValue: 0),
        today: RevenueMetrics(revenue: 0, totalSales: 0, avgOrderValue: 0),
      ),
    );
  }
}
