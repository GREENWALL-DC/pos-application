// All business logic.

const repo = require("./products.repository");

// This function gets all products from the database
exports.getAllProducts = async () => {
  // Call the repository to get all products from database
  const result = await repo.getAllProducts();
  // Return just the data rows (without database metadata)
  return result.rows;
};

exports.getProductById = async (id) => {
  const result = await repo.getProductById(id);
  if (result.rows.length === 0) throw new Error("Product not found ");
  return result.rows[0];
};

// CREATE NEW PRODUCT
// This function creates a product AND sets up its initial stock
exports.createProduct = async (data) => {
  const createRes = await repo.createProduct(data);
  const product = createRes.rows[0];

  //Also create stock row for this new product
  // This ensures every product has a stock record

  await repo.adjustStock({
    productId: product.id, // Use the ID of the newly created product
    quantityChange: 0, // Start with 0 stock initially
    reason: "product-created", // Reason for this stock entry
  });

  //return the created product
  return product;
};

// UPDATE EXISTING PRODUCT
// This function updates a product and tracks price changes
exports.updateProduct = async (id, data) => {
  const oldProduct = await repo.getProductById(id);
  if (oldProduct.rows.length === 0) throw new Error("Product not found");
  const oldPrice = oldProduct.rows[0].price;

  const updateRes = await repo.updateProduct(id, data);
  const updatedProduct = updateRes.rows[0];

  if (data.price && data.price != oldPrice) {
    await repo.addPriceHistory(id, oldPrice, data.price);
  }

  return updatedProduct;
};




exports.deleteProduct = async (id) => {
  const result = await repo.deleteProduct(id);

  if (result.rows.length === 0) throw new Error("Product not found");

  return result.rows[0];
};

exports.adjustStock = async(productId,quantityChange,reason)=>{
    const stockRes = await repo.adjustStock({
        productId,
        quantityChange,
        reason,
    });
    return stockRes.rows[0];
};

// GET STOCK INFORMATION
// This function gets current stock levels for a product
exports.getStockWithHistory = async (productId)=>{
    const stock = await repo.getStocksByProduct(productId);
    return stock.rows[0];
}
