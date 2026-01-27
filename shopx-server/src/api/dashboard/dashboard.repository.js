const db = require("../../config/db");

module.exports = {

 getTotalSales: async () => {
  return await db.query(`
    SELECT 
      COUNT(id) AS total_sales,
      COALESCE(SUM(subtotal_amount - discount_amount), 0) AS total_revenue,
      COALESCE(AVG(subtotal_amount - discount_amount), 0) AS avg_order_value
    FROM sales
    WHERE payment_status = 'paid'
      AND sale_status != 'voided'
  `);
},


  getTotalPayments: async () => {
    return await db.query(
      `SELECT COALESCE(SUM(amount), 0) AS total_payments FROM payments`
    );
  },

  getCustomerCount: async () => {
    return await db.query(`SELECT COUNT(*) AS total_customers FROM customers`);
  },

 getTodaySales: async () => {
  return await db.query(`
    SELECT 
      COALESCE(SUM(subtotal_amount - discount_amount), 0) AS today_sales
    FROM sales
    WHERE DATE(sale_date) = CURRENT_DATE
      AND payment_status = 'paid'
      AND sale_status != 'voided'
  `);
},


  getWeeklySales: async () => {
    return await db.query(`
    WITH days AS (
      SELECT unnest(ARRAY['MON','TUE','WED','THU','FRI','SAT','SUN']) AS day
    ),
   sales_data AS (
  SELECT 
    TO_CHAR(sale_date, 'DY') AS day,
    SUM(subtotal_amount - discount_amount) AS revenue,
    COUNT(*) AS transactions
  FROM sales
  WHERE sale_date >= CURRENT_DATE - INTERVAL '6 days'
    AND payment_status = 'paid'
    AND sale_status != 'voided'
  GROUP BY TO_CHAR(sale_date, 'DY')
)

    SELECT 
      d.day,
      COALESCE(s.revenue, 0) AS revenue,
      COALESCE(s.transactions, 0) AS transactions
    FROM days d
    LEFT JOIN sales_data s ON s.day = d.day
    ORDER BY array_position(
      ARRAY['MON','TUE','WED','THU','FRI','SAT','SUN'], d.day
    );
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

//  getSalesBySalesperson: async () => {
//   return await db.query(`
//     SELECT 
//       sp.name,
//       COALESCE(SUM(s.subtotal_amount - s.discount_amount), 0) AS total_sales
//     FROM salespersons sp
//     LEFT JOIN sales s 
//       ON s.salesperson_id = sp.id
//       AND s.payment_status = 'paid'
//       AND s.sale_status != 'voided'
//     GROUP BY sp.name
//     ORDER BY total_sales DESC
//   `);
// },

getSalesBySalesperson: async () => {
  return await db.query(`
    SELECT
      sp.id,
      sp.name,

      -- Weekly revenue (last 7 days)
      COALESCE(
        SUM(
          CASE
            WHEN s.sale_date >= CURRENT_DATE - INTERVAL '6 days'
             AND s.sale_status != 'voided'
             AND s.payment_status IN ('paid', 'pending')
            THEN (s.subtotal_amount - s.discount_amount)
            ELSE 0
          END
        ),
        0
      ) AS weekly_revenue,

      -- Monthly revenue (current month)
      COALESCE(
        SUM(
          CASE
            WHEN DATE_TRUNC('month', s.sale_date) = DATE_TRUNC('month', CURRENT_DATE)
             AND s.sale_status != 'voided'
             AND s.payment_status IN ('paid', 'pending')
            THEN (s.subtotal_amount - s.discount_amount)
            ELSE 0
          END
        ),
        0
      ) AS monthly_revenue

    FROM salespersons sp
    LEFT JOIN sales s
      ON s.salesperson_id = sp.id

    GROUP BY sp.id, sp.name
    ORDER BY monthly_revenue DESC;
  `);
},



getRecentSales: async () => {
  return await db.query(`
    SELECT DISTINCT ON (s.id)
      s.id,
      s.total_amount,
      c.name AS customer,
      s.sale_date,
      s.payment_status,
      s.sale_status
    FROM sales s
    LEFT JOIN customers c ON c.id = s.customer_id
    WHERE DATE(s.sale_date) = CURRENT_DATE
    ORDER BY 
      s.id,
      s.updated_at DESC
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

  getTotalDiscount: async () => {
    return await db.query(`
    SELECT 
      COALESCE(SUM(quantity * discount), 0) AS total_discount
    FROM sale_items
  `);
  },


  getTodayMetrics: async () => {
  return await db.query(`
    SELECT
      COUNT(id) AS today_sales,
      COALESCE(SUM(subtotal_amount - discount_amount), 0) AS today_revenue,
      COALESCE(
        CASE 
          WHEN COUNT(id) = 0 THEN 0
          ELSE SUM(subtotal_amount - discount_amount) / COUNT(id)
        END,
        0
      ) AS today_avg_order_value
    FROM sales
    WHERE DATE(sale_date) = CURRENT_DATE
      AND payment_status = 'paid'
      AND sale_status != 'voided'
  `);
},

};
