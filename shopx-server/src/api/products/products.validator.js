exports.validateCreateProduct = (req, res, next) => {
  const { name, price, quantity, category, code } = req.body;

  // Removed "unit"
  if (!name || !price || !quantity || !category || !code) {
    return res.status(400).json({
      message: "name, price, category, quantity, code are required",
    });
  }

  next();
};


// VALIDATE UPDATE PRODUCT - allow any one field except unit
exports.validateUpdateProduct = (req, res, next) => {
  if (
    !req.body.name &&
    !req.body.price &&
    !req.body.quantity &&
    !req.body.category &&
    !req.body.code
  ) {
    return res.status(400).json({
      message:
        "At least one field (name / price / quantity / category / code) must be provided",
    });
  }

  next();
};
