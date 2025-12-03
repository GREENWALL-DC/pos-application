const db = require("../../config/db");

// CREATE SALE
exports.createSale = async (client, { salesperson_id, customer_id, total_amount }) => {
  const result = await client.query(
    `INSERT INTO sales (salesperson_id, customer_id, total_amount, payment_status)
     VALUES ($1, $2, $3, 'unpaid')
     RETURNING *`,
    [salesperson_id, customer_id, total_amount]
  );
  return result.rows[0];
};

// CREATE SALE BALANCE
exports.createSaleBalance = async (client, sale_id, total_amount) => {
  return await client.query(
    `INSERT INTO sale_balance (sale_id, total_amount, paid_amount, balance)
     VALUES ($1, $2, 0, $2)`,
    [sale_id, total_amount]
  );
};

// INSERT SALE ITEM
exports.addSaleItem = async (client, sale_id, item) => {
  const total_price = item.quantity * item.unit_price;

  return await client.query(
    `INSERT INTO sale_items (sale_id, product_id, quantity, unit_price, total_price)
     VALUES ($1, $2, $3, $4, $5)`,
    [sale_id, item.product_id, item.quantity, item.unit_price, total_price]
  );
};

// FULL INVOICE JOIN
exports.getFullInvoice = async (id) => {
  const sale = await db.query(`
      SELECT s.*, 
             u.name AS salesperson_name,
             c.name AS customer_name, 
             c.phone AS customer_phone
      FROM sales s
      LEFT JOIN users u ON u.id = s.salesperson_id
      LEFT JOIN customers c ON c.id = s.customer_id
      WHERE s.id = $1
    `, [id]);

  const items = await db.query(`
      SELECT si.*, p.name AS product_name
      FROM sale_items si
      JOIN products p ON p.id = si.product_id
      WHERE si.sale_id = $1
    `, [id]);

  const payments = await db.query(
    `SELECT * FROM payments WHERE sale_id = $1 ORDER BY created_at ASC`,
    [id]
  );

  const balance = await db.query(
    `SELECT * FROM sale_balance WHERE sale_id = $1`,
    [id]
  );

  return {
    sale: sale.rows[0],
    items: items.rows,
    payments: payments.rows,
    balance: balance.rows[0],
  };
};

// BASIC LIST
exports.getAllSales = async () => {
  const r = await db.query(`SELECT * FROM sales ORDER BY id DESC`);
  return r.rows;
};
