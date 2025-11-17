const service = require("./sales.service");
const asyncHandler = require("express-async-handler");

exports.createSale = asyncHandler(async (req, res) => {
  const sale = await service.createSale(req.body);
  res.status(201).json({ message: "Sale created", sale });
});

exports.getSaleById = asyncHandler(async (req, res) => {
  const data = await service.getSale(req.params.id);
  res.json(data);
});

exports.getAllSales = asyncHandler(async (req, res) => {
  const sales = await service.getAllSales();
  res.json(sales);
});
 