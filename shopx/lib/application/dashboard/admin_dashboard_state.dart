enum SalesChartPeriod { daily, weekly, monthly }

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

//new
class DailyChange {
  final num revenueDiff;
  final num revenuePercent;
  final String direction; // "up" | "down" | "same"

  const DailyChange({
    required this.revenueDiff,
    required this.revenuePercent,
    required this.direction,
  });

  factory DailyChange.empty() {
    return const DailyChange(
      revenueDiff: 0,
      revenuePercent: 0,
      direction: "same",
    );
  }
}

// class AdminDashboardState {
//   final bool loading;
//   final String? error;

//   final Totals totals;

//   final num totalCustomers;
//   final num totalDiscount; // NEW

//   // charts
//   final List<Map<String, dynamic>> weeklySummary;
//   final List<Map<String, dynamic>> topProducts;
//   final List<Map<String, dynamic>> salesBySalesperson;

//   // tables
//   final List<Map<String, dynamic>> recentSales;
//   final List<Map<String, dynamic>> lowStock;
class AdminDashboardState {
  final bool loading;
  final String? error;

  final Totals totals;

  final num totalCustomers;
  final num totalDiscount;

  // 🔥 NEW: Sales chart period selector (Weekly / Monthly)
  final SalesChartPeriod chartPeriod;

  //new
  final num yesterdayRevenue;
  final DailyChange todayChange;

  // charts
  final List<Map<String, dynamic>> weeklySummary;
  final List<Map<String, dynamic>> topProducts;
  final List<Map<String, dynamic>> salesBySalesperson;

  // tables
  final List<Map<String, dynamic>> recentSales;
  final List<Map<String, dynamic>> lowStock;

  //new
  final List<Map<String, dynamic>> salesChart;

  const AdminDashboardState({
    this.loading = false,
    this.error,

    required this.totals,
    this.totalCustomers = 0,
    this.totalDiscount = 0, // NEW
    this.chartPeriod = SalesChartPeriod.weekly, // ✅ DEFAULT

    this.weeklySummary = const [],
    this.topProducts = const [],
    this.salesBySalesperson = const [],

    this.recentSales = const [],
    this.lowStock = const [],
    this.salesChart = const [],

    this.yesterdayRevenue = 0,
    this.todayChange = const DailyChange(
      revenueDiff: 0,
      revenuePercent: 0,
      direction: "same",
    ),
  });

  AdminDashboardState copyWith({
    bool? loading,
    String? error,
    Totals? totals,
    num? totalCustomers,
    num? totalDiscount, // NEW
    SalesChartPeriod? chartPeriod,

    List<Map<String, dynamic>>? weeklySummary,
    List<Map<String, dynamic>>? topProducts,
    List<Map<String, dynamic>>? salesBySalesperson,

    List<Map<String, dynamic>>? recentSales,
    List<Map<String, dynamic>>? lowStock,
    List<Map<String, dynamic>>? salesChart,

    num? yesterdayRevenue,
    DailyChange? todayChange,
  }) {
    return AdminDashboardState(
      loading: loading ?? this.loading,
      error: error,

      totals: totals ?? this.totals,

      totalCustomers: totalCustomers ?? this.totalCustomers,
      totalDiscount: totalDiscount ?? this.totalDiscount,
      chartPeriod: chartPeriod ?? this.chartPeriod,

      weeklySummary: weeklySummary ?? this.weeklySummary,
      topProducts: topProducts ?? this.topProducts,
      salesBySalesperson: salesBySalesperson ?? this.salesBySalesperson,

      recentSales: recentSales ?? this.recentSales,
      lowStock: lowStock ?? this.lowStock,
      salesChart: salesChart ?? this.salesChart,

      yesterdayRevenue: yesterdayRevenue ?? this.yesterdayRevenue,
      todayChange: todayChange ?? this.todayChange,
    );
  }

  // factory AdminDashboardState.initial() {
  //   return AdminDashboardState(
  //     totals: Totals(
  //       all: RevenueMetrics(revenue: 0, totalSales: 0, avgOrderValue: 0),
  //       today: RevenueMetrics(revenue: 0, totalSales: 0, avgOrderValue: 0),
  //     ),
  //   );
  // }
  factory AdminDashboardState.initial() {
    return AdminDashboardState(
      chartPeriod: SalesChartPeriod.weekly,
      yesterdayRevenue: 0,
      todayChange: DailyChange.empty(),
      totals: Totals(
        all: RevenueMetrics(revenue: 0, totalSales: 0, avgOrderValue: 0),
        today: RevenueMetrics(revenue: 0, totalSales: 0, avgOrderValue: 0),
      ),
    );
  }
}
