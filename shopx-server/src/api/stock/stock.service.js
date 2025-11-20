const db = require("../../config/db");
const repo = require("./stock.repository");

async function ensureStockRow(productId) {
  const existing = await repo.getStockByProduct(productId);
  if (!existing) {
    // create initial row with 0
    await repo.createStockRow(productId, 0);
    return { product_id: productId, quantity: 0 };
  }
  return existing;
}

/**
 * Adjust stock: qtyChange can be +ve (add) or -ve (remove)
 * Returns the updated stock row.
 */
async function adjustStock(productId, qtyChange, reason = "adjustment") {
  // ensure the stock row exists
  const stockRow = await ensureStockRow(productId);

  // If reducing, check availability
  if (qtyChange < 0) {
    if (stockRow.quantity + qtyChange < 0) {
      throw new Error("Insufficient stock");
    }
  }

  // Update stock
  const updated = await repo.updateStockQuantity(productId, qtyChange);

  // Insert movement record
  await repo.insertStockMovement(productId, qtyChange, reason);

  // Return updated row
  return updated;
}

async function getStock(productId) {
  const stock = await repo.getStockByProduct(productId);
  return stock;
}

async function getAllStock() {
  const rows = await repo.getAllStock();
  return rows;
}

async function getStockMovements(productId, limit = 100) {
  return await repo.getStockMovements(productId, limit);
}

module.exports = {
  adjustStock,
  getStock,
  getAllStock,
  getStockMovements,
  ensureStockRow,
};
