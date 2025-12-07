const db = require("../../config/db");

module.exports = {
  createPayment: async (client, { saleId, customerId, amount, method }) => {
    return await client.query(
      `INSERT INTO payments (sale_id, customer_id, amount, method)
     VALUES ($1, $2, $3, $4)
     RETURNING *`,
      [saleId, customerId, amount, method]
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
