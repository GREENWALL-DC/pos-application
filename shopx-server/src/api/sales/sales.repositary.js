const db = require("../../config/db");

// CREATE SALE

exports.createSale = async (
  client,
  {
    salesperson_id,
    customer_id,
    subtotal_amount,
    discount_amount,
    vat_percentage,
    vat_amount,
    total_amount,
  }
) => {
  const result = await client.query(
    `INSERT INTO sales 
     (
       salesperson_id,
       customer_id,
       subtotal_amount,
       discount_amount,
       vat_percentage,
       vat_amount,
       total_amount,
       payment_status
     )
     VALUES ($1, $2, $3, $4, $5, $6, $7, 'paid')
     RETURNING *`,
    [
      salesperson_id,
      customer_id,
      subtotal_amount,
      discount_amount,
      vat_percentage,
      vat_amount,
      total_amount,
    ]
  );

  return result.rows[0];
};



// INSERT SALE ITEM
exports.addSaleItem = async (client, sale_id, item) => {
  const discount = item.discount || 0;

  const total_price = item.quantity * (item.unit_price - discount);

  return await client.query(
    `INSERT INTO sale_items 
     (sale_id, product_id, quantity, fulfilled_quantity, unit_price, discount, total_price)
     VALUES ($1, $2, $3, $4, $5, $6, $7)`,
    [
      sale_id,
      item.product_id,
      item.quantity,
      0, // 👈 fulfilled_quantity ALWAYS starts at 0
      item.unit_price,
      discount,
      total_price,
    ]
  );
};

exports.updateSaleStatus = async (client, saleId, status) => {
  await client.query(`UPDATE sales SET sale_status = $1 WHERE id = $2`, [
    status,
    saleId,
  ]);
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
    SELECT 
      si.id,
      si.sale_id,
      si.product_id,
      si.product_name,
      si.product_name_ar,
      si.quantity,
      si.fulfilled_quantity,
      si.unit_price,
      si.discount,
      si.total_price
    FROM sale_items si
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
