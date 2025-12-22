exports.validateCreateProduct = (req, res, next) => {
const { name, price, quantity, category, code, vat } = req.body;

  // Removed "unit"
 if (!name || !price || !category || !code || vat == null) {
  return res.status(400).json({
    message: "name, price, category, code, vat are required",
  });
}


  next();
};


// VALIDATE UPDATE PRODUCT - allow any one field except unit
exports.validateUpdateProduct = (req, res, next) => {
  if (
    req.body.name == null &&
    req.body.price == null &&
    req.body.category == null &&
    req.body.code == null &&
    req.body.vat == null
  ) {
    return res.status(400).json({
      message:
        "At least one field (name / price / category / code / vat) must be provided",
    });
  }

  next();
};

