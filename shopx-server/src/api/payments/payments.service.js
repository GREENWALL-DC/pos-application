const repo = require("./payments.repository");
const db = require("../../config/db");

// ✅ ADD PAYMENT (PAID or PENDING)
exports.addPayment = async ({ saleId, customerId, amount, method, status }) => {
  const client = await db.connect();
  const paymentStatus = status || "paid";

  try {
    await client.query("BEGIN");

    const payment = await repo.createPayment(client, {
      saleId,
      customerId,
      amount,
      method,
      status: paymentStatus,
    });

await repo.updateSalePaymentStatus(client, saleId, paymentStatus);

    await client.query("COMMIT");

    return {
      payment: payment.rows[0],
      payment_status: paymentStatus,
    };
  } catch (err) {
    await client.query("ROLLBACK");
    throw err;
  } finally {
    client.release();
  }
};


// ✅ Mark pending → paid (used after 4–5 days)
exports.markPaymentAsPaid = async (saleId) => {
  const client = await db.connect();

  try {
    await client.query("BEGIN");

    // 🔒 Lock sale row
    const saleRes = await client.query(
      `SELECT sale_status FROM sales WHERE id = $1 FOR UPDATE`,
      [saleId]
    );

    const sale = saleRes.rows[0];

    if (!sale) {
      throw new Error("Sale not found");
    }

    if (sale.sale_status === "voided") {
      throw new Error("Cannot mark payment for cancelled sale");
    }

    // ✅ Mark payments
    await repo.markPaymentsAsPaid(client, saleId);

    // ✅ Update sale payment status
    await repo.updateSalePaymentStatus(client, saleId, "paid");

    await client.query("COMMIT");

    return {
      saleId,
      payment_status: "paid",
    };
  } catch (err) {
    await client.query("ROLLBACK");
    throw err;
  } finally {
    client.release();
  }
};


exports.getPaymentsOfSale = async (saleId) => {
  return await repo.getPaymentsBySale(saleId);
};
