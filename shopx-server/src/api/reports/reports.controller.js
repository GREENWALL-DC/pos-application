const asyncHandler = require("express-async-handler");
const service = require("./reports.service");

// GET /api/reports/daily?from=2025-11-01&to=2025-11-15
exports.dailySales = asyncHandler(async (req, res) => {
  const { from, to } = req.query;
  const rows = await service.getDailySales(from, to);
  res.json({ report: rows });
});

// GET /api/reports/monthly?year=2025
exports.monthlySales = asyncHandler(async (req, res) => {
  const { year } = req.query;
  const rows = await service.getMonthlySales(year);
  res.json({ report: rows });
});

// GET /api/reports/salesperson?from=&to=
exports.salesBySalesperson = asyncHandler(async (req, res) => {
  const { from, to } = req.query;
  const rows = await service.getSalesBySalesperson(from, to);
  res.json({ report: rows });
});

// GET /api/reports/products?from=&to=&limit=
exports.productSales = asyncHandler(async (req, res) => {
  const { from, to, limit } = req.query;
  const rows = await service.getProductSales(from, to, limit || 50);
  res.json({ report: rows });
});

// GET /api/reports/customer-ledger/:customerId
exports.customerLedger = asyncHandler(async (req, res) => {
  const { customerId } = req.params;
  const ledger = await service.getCustomerLedger(customerId);
  res.json({ ledger });
});

// GET /api/reports/outstanding
exports.outstandingByCustomer = asyncHandler(async (req, res) => {
  const rows = await service.getOutstandingByCustomer();
  res.json({ outstanding: rows });
});


exports.myDailySales = asyncHandler(async (req, res) => {
  const { from, to } = req.query;
  const salespersonId = req.user.id; // logged-in user
  const report = await service.getMyDailySales(salespersonId, from, to);
  res.json({ report });
});

exports.myMonthlySales = asyncHandler(async (req, res) => {
  const { year } = req.query;
  const salespersonId = req.user.id;
  const report = await service.getMyMonthlySales(salespersonId, year);
  res.json({ report });
});
