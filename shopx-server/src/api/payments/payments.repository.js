const db = require("../../config/db");

module.exports = {
  // ✅ Create payment (paid OR pending)
  createPayment: async (
    client,
    { saleId, customerId, amount, method, status }
  ) => {
    return await client.query(
      `INSERT INTO payments (sale_id, customer_id, amount, method, status)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [saleId, customerId, amount, method, status]
    );
  },

  // ✅ Get all payments of a sale
  getPaymentsBySale: async (saleId) => {
    return await db.query(
      `SELECT * FROM payments WHERE sale_id = $1 ORDER BY created_at ASC`,
      [saleId]
    );
  },

  // ✅ Mark ALL pending payments of a sale as PAID
 markPaymentsAsPaid: async (client, saleId) => {
  return await client.query(
    `UPDATE payments
     SET status = 'paid'
     WHERE sale_id = $1 AND status = 'pending'`,
    [saleId]
  );
},


  // ✅ Reverse payments when sale is voided
  reversePaymentBySaleId: async (client, saleId) => {
    return await client.query(
      `UPDATE payments
       SET status = 'reversed'
       WHERE sale_id = $1 AND status = 'paid'`,
      [saleId]
    );
  },

  // ✅ Update sale payment status (paid / pending)
  updateSalePaymentStatus: async (saleId, status) => {
    return await db.query(
      `UPDATE sales SET payment_status = $1 WHERE id = $2`,
      [status, saleId]
    );
  },
};
