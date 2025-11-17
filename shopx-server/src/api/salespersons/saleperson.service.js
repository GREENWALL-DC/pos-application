const repo = require("./saleperson.repositary");
const {validateSalesperson}=require("./saleperson.validator");


exports.createSalesperson = async (data) => {
  const errors = validateSalesperson(data);
  if (errors.length > 0) throw new Error(errors.join(", "));

  return await repo.createSalesperson(data);
};

exports.getAllSalespersons = async () => {
  return await repo.findAll();
};

exports.getSalesperson = async (id) => {
  const person = await repo.findById(id);
  if (!person) throw new Error("Salesperson not found");

  return person;
};

exports.updateSalesperson = async (id, data) => {
  const updated = await repo.updateSalesperson(id, data);
  if (!updated) throw new Error("Salesperson not found");

  return updated;
};

exports.deleteSalesperson = async (id) => {
  const deleted = await repo.deleteSalesperson(id);
  if (!deleted) throw new Error("Salesperson not found");

  return deleted;
};