const db = require("../../config/db");

/**
 * Daily sales totals (sum of sale total_amount) grouped by day
 * params: fromDate (YYYY-MM-DD) optional, toDate optional
 */
exports.dailySales = async (fromDate, toDate) => {
  const params = [];
  let where = "";
  if (fromDate) {
    params.push(fromDate);
    where += ` AND s.created_at::date >= $${params.length}`;
  }
  if (toDate) {
    params.push(toDate);
    where += ` AND s.created_at::date <= $${params.length}`;
  }

  const q = `
    SELECT
      date_trunc('day', s.sale_date) AS day,
      COUNT(*) AS sales_count,
      COALESCE(SUM(s.total_amount),0) AS total_sales
    FROM sales s
    WHERE 1=1 ${where}
    GROUP BY day
    ORDER BY day DESC;
  `;
  return await db.query(q, params);
};

/**
 * Monthly sales totals grouped by month
 */
exports.monthlySales = async (year) => {
  const params = [];
  let where = "";
  if (year) {
    params.push(`${year}-01-01`);
    params.push(`${year}-12-31`);
    where = `WHERE s.created_at::date BETWEEN $1 AND $2`;
  }

  const q = `
    SELECT
      date_trunc('month', s.sale_date) AS month,
      COUNT(*) AS sales_count,
      COALESCE(SUM(s.total_amount),0) AS total_sales
    FROM sales s
    ${where}
    GROUP BY month
    ORDER BY month DESC;
  `;
  return await db.query(q, params);
};

/**
 * Sales by salesperson (range optional)
 */
exports.salesBySalesperson = async (fromDate, toDate) => {
  const params = [];
  let where = "";
  if (fromDate) {
    params.push(fromDate);
    where += ` AND s.sale_date::date >= $${params.length}`;
  }
  if (toDate) {
    params.push(toDate);
    where += ` AND s.sale_date::date <= $${params.length}`;
  }

  const q = `
    SELECT
      sp.id AS salesperson_id,
      sp.name AS salesperson_name,
      COUNT(s.id) AS sales_count,
      COALESCE(SUM(s.total_amount),0) AS total_sales
    FROM sales s
    LEFT JOIN salespersons sp ON sp.id = s.salesperson_id
    WHERE 1=1 ${where}
    GROUP BY sp.id, sp.name
    ORDER BY total_sales DESC;
  `;
  return await db.query(q, params);
};

/**
 * Product-wise sales (units and revenue) in date range
 */
exports.productSales = async (fromDate, toDate, limit = 50) => {
  const params = [];
  let where = "";
  if (fromDate) {
    params.push(fromDate);
    where += ` AND s.sale_date::date >= $${params.length}`;
  }
  if (toDate) {
    params.push(toDate);
    where += ` AND s.sale_date::date <= $${params.length}`;
  }
  params.push(limit);

  const q = `
    SELECT
      p.id AS product_id,
      p.name AS product_name,
      COALESCE(SUM(si.quantity),0) AS total_units,
      COALESCE(SUM(si.total_price),0) AS total_revenue
    FROM sale_items si
    JOIN sales s ON s.id = si.sale_id
    JOIN products p ON p.id = si.product_id
    WHERE 1=1 ${where}
    GROUP BY p.id, p.name
    ORDER BY total_units DESC
    LIMIT $${params.length};
  `;
  return await db.query(q, params);
};

/**
 * Customer ledger (sales + payments) for a given customer_id
 */
exports.customerLedger = async (customerId) => {
  const qSales = `
    SELECT s.id, s.sale_date, s.total_amount
    FROM sales s
    WHERE s.customer_id = $1
    ORDER BY s.sale_date DESC;
  `;
  const qPayments = `
    SELECT p.id, p.sale_id, p.payment_date, p.amount, p.payment_method
    FROM payments p
    JOIN sales s ON s.id = p.sale_id
    WHERE s.customer_id = $1
    ORDER BY p.payment_date DESC;
  `;

  const sales = await db.query(qSales, [customerId]);
  const payments = await db.query(qPayments, [customerId]);

  return { sales: sales.rows, payments: payments.rows };
};

/**
 * Outstanding balances per customer (customer id, name, total_sales, total_paid, balance)
 */
exports.outstandingByCustomer = async () => {
  const q = `
    SELECT
      c.id AS customer_id,
      c.name AS customer_name,
      COALESCE(SUM(s.total_amount),0) AS total_sales,
      COALESCE(SUM(p.amount),0) AS total_paid,
      COALESCE(SUM(s.total_amount),0) - COALESCE(SUM(p.amount),0) AS balance
    FROM customers c
    LEFT JOIN sales s ON s.customer_id = c.id
    LEFT JOIN payments p ON p.sale_id = s.id
    GROUP BY c.id, c.name
    HAVING COALESCE(SUM(s.total_amount),0) - COALESCE(SUM(p.amount),0) > 0
    ORDER BY balance DESC;
  `;
  return await db.query(q);
};


//user endpoints for reports
exports.myDailySales = async (salespersonId, from, to) => {
  const params = [salespersonId];
  let where = `WHERE s.salesperson_id = $1`;

  if (from) {
    params.push(from);
    where += ` AND s.sale_date::date >= $${params.length}`;
  }

  if (to) {
    params.push(to);
    where += ` AND s.sale_date::date <= $${params.length}`;
  }

  const q = `
    SELECT 
      date_trunc('day', s.sale_date) AS day,
      COUNT(*) AS sales_count,
      SUM(s.total_amount) AS total_sales
    FROM sales s
    ${where}
    GROUP BY day
    ORDER BY day DESC;
  `;

  return await db.query(q, params);
};


exports.myMonthlySales = async (salespersonId, year) => {
  const params = [salespersonId];
  let where = `WHERE s.salesperson_id = $1`;

  if (year) {
    params.push(`${year}-01-01`);
    params.push(`${year}-12-31`);
    where += ` AND s.sale_date::date BETWEEN $2 AND $3`;
  }

  const q = `
    SELECT
      date_trunc('month', s.sale_date) AS month,
      COUNT(*) AS sales_count,
      SUM(s.total_amount) AS total_sales
    FROM sales s
    ${where}
    GROUP BY month
    ORDER BY month DESC;
  `;

  return await db.query(q, params);
};
