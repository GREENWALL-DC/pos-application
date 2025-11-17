const db = require("../../config/db");

// Create main sale row
exports.createSale = async ({ salesperson_id, customer_id, total_amount }) => {
  const result = await db.query(
    `INSERT INTO sales (salesperson_id, customer_id, total_amount)
     VALUES ($1, $2, $3) RETURNING *`,
    [salesperson_id, customer_id, total_amount]
  );

  return result.rows[0];
};

// Insert sale items
exports.addSaleItem = async (sale_id, { product_id, quantity, unit_price }) => {
  const total_price = quantity * unit_price;

  const result = await db.query(
    `INSERT INTO sale_items (sale_id, product_id, quantity, unit_price, total_price)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING *`,
    [sale_id, product_id, quantity, unit_price, total_price]
  );

  return result.rows[0];
};

// Get by ID
exports.getSaleById = async (id) => {
  const sale = await db.query(
    `SELECT * FROM sales WHERE id = $1`,
    [id]
  );

  const items = await db.query(
    `SELECT * FROM sale_items WHERE sale_id = $1`,
    [id]
  );

  return { sale: sale.rows[0], items: items.rows };
};

// Get all sales
exports.getAllSales = async () => {
  const result = await db.query(`
    SELECT * FROM sales ORDER BY id DESC
  `);
  return result.rows;
};
