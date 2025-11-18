const repo = require("./dashboard.repository");

exports.getDashboardData = async () => {
  const totalSales = await repo.getTotalSales();
  const totalPayments = await repo.getTotalPayments();
  const pendingAmount = await repo.getPendingAmount();
  const todaySales = await repo.getTodaySales();
  const topProducts = await repo.getTopProducts();
  const salesBySalesperson = await repo.getSalesBySalesperson();
  const recentSales = await repo.getRecentSales();
  const lowStock = await repo.getLowStock();

  return {
    totals: {
      total_sales: Number(totalSales.rows[0].total_sales),
      total_payments: Number(totalPayments.rows[0].total_payments),
      pending_amount: Number(pendingAmount.rows[0].pending_amount),
      today_sales: Number(todaySales.rows[0].today_sales),
    },
    charts: {
      top_products: topProducts.rows,
      sales_by_salesperson: salesBySalesperson.rows,
    },
    tables: {
      recent_sales: recentSales.rows,
      low_stock: lowStock.rows,
    },
  };
};
