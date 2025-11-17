const service = require("./saleperson.service");
const asyncHandler = require("express-async-handler");

exports.create = asyncHandler(async (req, res) => {
  const person = await service.createSalesperson(req.body);
  res.status(201).json({ message: "Salesperson created", person });
});

exports.getAll = asyncHandler(async (req, res) => {
  const persons = await service.getAllSalespersons();
  res.json(persons);
});


exports.getOne = asyncHandler(async (req, res) => {
  const person = await service.getSalesperson(req.params.id);
  res.json(person);
});

exports.update = asyncHandler(async (req, res) => {
  const person = await service.updateSalesperson(req.params.id, req.body);
  res.json({ message: "Salesperson updated", person });
});

exports.remove = asyncHandler(async (req, res) => {
  await service.deleteSalesperson(req.params.id);
  res.json({ message: "Salesperson deleted" });
});