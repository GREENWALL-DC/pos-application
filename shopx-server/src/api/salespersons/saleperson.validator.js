exports.validateSalesperson = (data) => {
  const errors = [];

  if (!data.name) errors.push("Salesperson name is required");
  if (!data.phone) errors.push("Phone number is required");

  return errors;
};
