const asyncHandler = require("express-async-handler");
const service = require("./payments.service");

exports.addPayment = asyncHandler(async (req, res) => {
  const { saleId, customerId, amount, method } = req.body;

  const result = await service.addPayment({ saleId, customerId, amount, method });
  res.json(result);
});

exports.getPayments = asyncHandler(async (req, res) => {
  const { saleId } = req.params;

  const payments = await service.getPaymentsOfSale(saleId);
  res.json(payments.rows);
});
