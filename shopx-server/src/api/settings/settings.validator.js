// src/api/settings/settings.validator.js

function validateCompanySettings(req, res, next) {
  // Optional: basic sanity checks only
  const { vatNumber, email } = req.body;

  if (vatNumber && vatNumber.length < 5) {
    return res.status(400).json({
      message: "Invalid VAT number",
    });
  }

  if (email && !email.includes("@")) {
    return res.status(400).json({
      message: "Invalid email format",
    });
  }

  next();
}

module.exports = {
  validateCompanySettings,
};
