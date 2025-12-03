const asyncHandler = require("express-async-handler");
const service = require("./sales.service");

exports.createSale = asyncHandler(async (req, res) => {
  const data = req.body;

  // Automatically take salesperson from token
  data.salesperson_id = req.user.id;

  const sale = await service.createSale(data);

  res.status(201).json({
    message: "Sale created successfully",
    sale,
  });
});

exports.getSaleById = asyncHandler(async (req, res) => {
  const invoice = await service.getFullInvoice(req.params.id);
  res.json(invoice);
});

exports.getAllSales = asyncHandler(async (req, res) => {
  const sales = await service.getAllSales();
  res.json(sales);
});
