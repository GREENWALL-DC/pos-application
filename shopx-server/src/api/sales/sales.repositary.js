const db = require("../../config/db");

// CREATE SALE
exports.createSale = async (
  client,
  { salesperson_id, customer_id, total_amount }
) => {
  const result = await client.query(
    `INSERT INTO sales (salesperson_id, customer_id, total_amount, payment_status)
     VALUES ($1, $2, $3, 'paid')
     RETURNING *`,
    [salesperson_id, customer_id, total_amount]
  );
  return result.rows[0];
};

// INSERT SALE ITEM
exports.addSaleItem = async (client, sale_id, item) => {
  const discount = item.discount || 0;

  const total_price = item.quantity * (item.unit_price - discount);

  return await client.query(
    `INSERT INTO sale_items (sale_id, product_id, quantity, unit_price, discount, total_price)
     VALUES ($1, $2, $3, $4, $5, $6)`,
    [
      sale_id,
      item.product_id,
      item.quantity,
      item.unit_price,
      discount,
      total_price
    ]
  );
};

// FULL INVOICE JOIN
exports.getFullInvoice = async (id) => {
  const sale = await db.query(
    `
      SELECT s.*, 
             u.username AS salesperson_name,
             c.name AS customer_name, 
             c.phone AS customer_phone
      FROM sales s
      LEFT JOIN users u ON u.id = s.salesperson_id
      LEFT JOIN customers c ON c.id = s.customer_id
      WHERE s.id = $1
    `,
    [id]
  );

  const items = await db.query(
    `
      SELECT si.*, p.name AS product_name
      FROM sale_items si
      JOIN products p ON p.id = si.product_id
      WHERE si.sale_id = $1
    `,
    [id]
  );

  const payments = await db.query(
    `SELECT * FROM payments WHERE sale_id = $1 ORDER BY created_at ASC`,
    [id]
  );

  return {
    sale: sale.rows[0],
    items: items.rows,
    payments: payments.rows,
  };
};

// BASIC LIST
exports.getAllSales = async () => {
  const r = await db.query(`SELECT * FROM sales ORDER BY id DESC`);
  return r.rows;
};
