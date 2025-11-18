const db = require("../../config/db");

module.exports = {
  createPayment: async ({ saleId, customerId, amount, method }) => {
    return await db.query(
      `INSERT INTO payments (sale_id, customer_id, amount, method)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [saleId, customerId, amount, method]
    );
  },

  getSaleBalance: async (saleId) => {
    return await db.query(
      `SELECT * FROM sale_balance WHERE sale_id = $1`,
      [saleId]
    );
  },

  updateSaleBalance: async ({ saleId, paidAmount, balance }) => {
    return await db.query(
      `UPDATE sale_balance
       SET paid_amount = $1, balance = $2
       WHERE sale_id = $3
       RETURNING *`,
      [paidAmount, balance, saleId]
    );
  },

  getPaymentsBySale: async (saleId) => {
    return await db.query(
      `SELECT * FROM payments WHERE sale_id = $1 ORDER BY created_at ASC`,
      [saleId]
    );
  },

  updateSaleStatus: async (saleId, status) => {
  return await db.query(
    `UPDATE sales SET payment_status = $1 WHERE id = $2`,
    [status, saleId]
  );
},

};
