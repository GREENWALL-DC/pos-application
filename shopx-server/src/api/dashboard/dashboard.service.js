const repo = require("./dashboard.repository");

exports.getDashboardData = async () => {
  const totalSales = await repo.getTotalSales();
  const todayMetrics = await repo.getTodayMetrics();
  const yesterdayMetrics = await repo.getYesterdayMetrics();
  const totalPayments = await repo.getTotalPayments(); // optional
  // const todaySales = await repo.getTodaySales();
  const topProducts = await repo.getTopProducts();
  const salesBySalesperson = await repo.getSalesBySalesperson();
  const recentSales = await repo.getRecentSales();
  const lowStock = await repo.getLowStock();
  const customerCount = await repo.getCustomerCount();
  const weeklySales = await repo.getWeeklySales();
  const totalDiscount = await repo.getTotalDiscount();

  //new
  
const todayRevenue = Number(todayMetrics.rows[0].today_revenue);
const yesterdayRevenue = Number(
  yesterdayMetrics.rows[0].yesterday_revenue
);

// comparison calculation
let revenueDiff = todayRevenue - yesterdayRevenue;
let revenuePercent = 0;

if (yesterdayRevenue > 0) {
  revenuePercent = (revenueDiff / yesterdayRevenue) * 100;
}

const revenueDirection =
  revenueDiff > 0 ? "up" : revenueDiff < 0 ? "down" : "same";


  return {
    totals: {
      all: {
        revenue:
          // Number(totalSales.rows[0].total_revenue) -
          // Number(totalDiscount.rows[0].total_discount),
           Number(totalSales.rows[0].total_revenue),

        total_sales: Number(totalSales.rows[0].total_sales),

        avg_order_value: Number(totalSales.rows[0].avg_order_value),
      },

      today: {
        revenue: Number(todayMetrics.rows[0].today_revenue),

        total_sales: Number(todayMetrics.rows[0].today_sales),

        avg_order_value: Number(todayMetrics.rows[0].today_avg_order_value),
      },

      
yesterday: {
  revenue: yesterdayRevenue,
},

today_change: {
  revenue_diff: revenueDiff,
  revenue_percent: Number(revenuePercent.toFixed(2)),
  direction: revenueDirection,
},

      // unrelated global metrics (stay outside scope)
      total_customers: Number(customerCount.rows[0].total_customers),
      total_discount: Number(totalDiscount.rows[0].total_discount),
      total_payments: Number(totalPayments.rows[0].total_payments),
    },

    charts: {
      top_products: topProducts.rows,
      // sales_by_salesperson: salesBySalesperson.rows,
       sales_by_salesperson: salesBySalesperson.rows.map(row => ({
    id: row.id,
    name: row.name,
    weekly_revenue: Number(row.weekly_revenue),
    monthly_revenue: Number(row.monthly_revenue),
  })),
      weekly_summary: weeklySales.rows,
    },

    tables: {
      recent_sales: recentSales.rows,
      low_stock: lowStock.rows,
    },
  };
};

// 📊 Sales chart data for dashboard (Day / Week / Month)
exports.getSalesChart = async (range) => {
  const result = await repo.getSalesChartData(range);

  return result.rows.map((row) => ({
    label: row.label,
    revenue: Number(row.revenue),
  }));
};

