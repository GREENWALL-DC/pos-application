const repo = require("./reports.repository");

exports.getDailySales = async (fromDate, toDate) => {
  const result = await repo.dailySales(fromDate, toDate);
  return result.rows;
};

exports.getMonthlySales = async (year) => {
  const result = await repo.monthlySales(year);
  return result.rows;
};

exports.getSalesBySalesperson = async (fromDate, toDate) => {
  const result = await repo.salesBySalesperson(fromDate, toDate);
  return result.rows;
};

exports.getProductSales = async (fromDate, toDate, limit) => {
  const result = await repo.productSales(fromDate, toDate, limit);
  return result.rows;
};

exports.getCustomerLedger = async (customerId) => {
  if (!customerId) throw new Error("customerId is required");
  return await repo.customerLedger(customerId);
};

exports.getOutstandingByCustomer = async () => {
  const result = await repo.outstandingByCustomer();
  return result.rows;
};

//user endpoints for reports
exports.getMyDailySales = async (salespersonId, from, to) => {
  const result = await repo.myDailySales(salespersonId, from, to);
  return result.rows;
};

exports.getMyMonthlySales = async (salespersonId, year) => {
  const result = await repo.myMonthlySales(salespersonId, year);
  return result.rows;
};
