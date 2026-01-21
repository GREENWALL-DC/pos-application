// src/api/settings/settings.validator.js

function validateCompanySettings(req, res, next) {
  const {
    companyNameEn,
    companyNameAr,
    companyAddressEn,
    companyAddressAr,
    vatNumber,
    crNumber,
  } = req.body;

  if (
    !companyNameEn ||
    !companyNameAr ||
    !companyAddressEn ||
    !companyAddressAr ||
    !vatNumber ||
    !crNumber
  ) {
    return res.status(400).json({
      message: "Missing required company fields",
    });
  }

  next();
}


module.exports = {
  validateCompanySettings,
};
