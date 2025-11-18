const db = require("../../config/db");

module.exports = {
  getTotalSales: async () => {
    return await db.query(`SELECT COALESCE(SUM(total_amount), 0) AS total_sales FROM sales`);
  },

  getTotalPayments: async () => {
    return await db.query(`SELECT COALESCE(SUM(amount), 0) AS total_payments FROM payments`);
  },

  getPendingAmount: async () => {
    return await db.query(`SELECT COALESCE(SUM(balance), 0) AS pending_amount FROM sale_balance`);
  },

  getTodaySales: async () => {
    return await db.query(`
      SELECT COALESCE(SUM(total_amount), 0) AS today_sales
      FROM sales
      WHERE DATE(sale_date) = CURRENT_DATE
    `);
  },

  getTopProducts: async () => {
    return await db.query(`
      SELECT p.name, SUM(si.quantity) AS total_qty
      FROM sale_items si
      JOIN products p ON p.id = si.product_id
      GROUP BY p.name
      ORDER BY total_qty DESC
      LIMIT 5
    `);
  },

  getSalesBySalesperson: async () => {
    return await db.query(`
      SELECT sp.name, COALESCE(SUM(s.total_amount),0) AS total_sales
      FROM salespersons sp
      LEFT JOIN sales s ON s.salesperson_id = sp.id
      GROUP BY sp.name
      ORDER BY total_sales DESC
    `);
  },

  getRecentSales: async () => {
    return await db.query(`
      SELECT s.id, s.total_amount, c.name AS customer, s.sale_date
      FROM sales s
      LEFT JOIN customers c ON c.id = s.customer_id
      ORDER BY s.sale_date DESC
      LIMIT 10
    `);
  },

  getLowStock: async () => {
    return await db.query(`
      SELECT p.name, s.quantity
      FROM stock s
      JOIN products p ON p.id = s.product_id
      WHERE s.quantity < 10
      ORDER BY s.quantity ASC
    `);
  },
};
