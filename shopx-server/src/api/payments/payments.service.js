const repo = require("./payments.repository");

exports.addPayment = async ({ saleId, customerId, amount, method }) => {
  // 1️⃣ Create one payment (always full)
  const payment = await repo.createPayment({
    saleId,
    customerId,
    amount,
    method
  });

  // 2️⃣ Mark sale status as PAID
  await repo.updateSaleStatus(saleId, "paid");

  // 3️⃣ Return final result
  return {
    payment: payment.rows[0],
    payment_status: "paid"
  };
};

exports.getPaymentsOfSale = async (saleId) => {
  return await repo.getPaymentsBySale(saleId);
};
