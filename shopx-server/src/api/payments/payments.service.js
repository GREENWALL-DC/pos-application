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

    await repo.updateSalePaymentStatus(saleId, paymentStatus);

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

    // 1️⃣ Mark payments as PAID
    await repo.markPaymentsAsPaid(client, saleId);

    // 2️⃣ Update sale payment status
    await repo.updateSalePaymentStatus(saleId, "paid");

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
