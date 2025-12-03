exports.validateCreateProduct = (req,res,next)=>{
 const { name, price, unit, quantity, category, code } = req.body;

if (!name || !price || !unit || !quantity || !category || !code) {
  return res.status(400).json({
    message: "name, price, category, quantity, unit, code are required"
  });
}


  // If all fields are present, move to the next middleware/controller
    next();
}


// VALIDATE UPDATE PRODUCT - For PUT /products/:id
// This checks if at least one field is provided when updating a product

exports.validateUpdateProduct = (req, res, next) => {
  if (!req.body.name && !req.body.price && !req.body.unit) {
    return res.status(400).json({
      message: "At least one field (name/price/unit) must be provided",
    });
  }

  next();
};