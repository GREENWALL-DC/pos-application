//Purpose: Small, clean.
//  Takes request → calls service → returns response.
 
const asyncHandler = require("express-async-handler");
const service = require("./products.service");

// GET /products
exports.getAllProducts = asyncHandler(async(req,res)=>{
    const products = await service.getAllProducts();
    res.json(products);
});


// GET /products/:id
exports.getProductById = asyncHandler(async(req,res)=>{
    const product =await service.getProductById(req.params.id);
    res.json(product);
});

// POST /products
exports.createProduct = asyncHandler(async (req, res) => {
  // 1️⃣ Create product without images first
  const product = await service.createProduct(req.body);

  // 2️⃣ If images uploaded → save them
  if (req.files && req.files.length > 0) {
    await service.saveProductImages(product.id, req.files);
  }

  res.status(201).json({
    message: "Product created",
    product,
  });
});


// PUT /products/:id
exports.updateProduct = asyncHandler(async(req,res)=>{
    const updated = await service.updateProduct(req.params.id,req.body);
    res.json(updated);
});

// DELETE /products/:id
exports.deleteProduct = asyncHandler(async(req,res)=>{
    await service.deleteProduct(req.params.id);
    res.json({message: "Product deleted"} );
});



// POST /products/:id/adjust-stock
exports.adjustStock = asyncHandler(async (req, res) => {
  const { quantity, reason } = req.body;

  const stock = await service.adjustStock({
    productId: req.params.id,
    quantityChange: quantity,
    reason: reason || "manual",
  });

  res.json(stock);
});
