const asyncHandler = require("express-async-handler");
const service = require("./payments.service");

// ✅ Create payment (paid OR pending)
exports.addPayment = asyncHandler(async (req, res) => {
  const { saleId, customerId, amount, method, status } = req.body;

  const result = await service.addPayment({
    saleId,
    customerId,
    amount,
    method,
    status, // 'paid' or 'pending'
  });

  res.json(result);
});

// ✅ Get all payments of a sale
exports.getPayments = asyncHandler(async (req, res) => {
  const { saleId } = req.params;

  const payments = await service.getPaymentsOfSale(saleId);
  res.json(payments.rows);
});

// ✅ NEW: Mark pending payment as PAID
exports.markPaymentAsPaid = asyncHandler(async (req, res) => {
  const { saleId } = req.params;

  const result = await service.markPaymentAsPaid(saleId);

  res.json({
    message: "Payment marked as PAID",
    result,
  });
});
