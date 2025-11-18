const repo = require("./payments.repository");

exports.addPayment = async ({ saleId, customerId, amount, method }) => {
  // Fetch sale balance
  const saleBalance = await repo.getSaleBalance(saleId);
  if (saleBalance.rows.length === 0) throw new Error("Sale not found");

  const balance = saleBalance.rows[0];
  const newPaidAmount = Number(balance.paid_amount) + Number(amount);
  const newBalance = Number(balance.total_amount) - newPaidAmount;

  if (newBalance < 0) throw new Error("Payment exceeds remaining balance");

  // Create payment record
  const payment = await repo.createPayment({ saleId, customerId, amount, method });

  // Update balance sheet
  await repo.updateSaleBalance({
    saleId,
    paidAmount: newPaidAmount,
    balance: newBalance,
  });

  // 🔥 Determine new payment status based on balance
let newStatus = "unpaid";

if (newBalance === 0) {
  newStatus = "paid";
} else if (newPaidAmount > 0 && newBalance > 0) {
  newStatus = "partial";
}

// 🔥 Update sale payment_status in sales table
await repo.updateSaleStatus(saleId, newStatus);

return {
  payment: payment.rows[0],
  updatedBalance: {
    total: balance.total_amount,
    paid: newPaidAmount,
    balance: newBalance,
    payment_status: newStatus
  }
};

};

exports.getPaymentsOfSale = async (saleId) => {
  return await repo.getPaymentsBySale(saleId);
};
