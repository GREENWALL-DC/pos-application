const repo = require("./sales.repositary");
const { validateSale } = require("./sales.validator");
const db = require("../../config/db");

// STOCK REDUCTION LOGIC
const reduceStock = async (product_id, qty) => {
  await db.query(
    `UPDATE stock SET quantity = quantity - $1 WHERE product_id = $2`,
    [qty, product_id]
  );

  await db.query(
    `INSERT INTO stock_movements (product_id, change, reason)
     VALUES ($1, $2, $3)`,
    [product_id, -qty, "sale"]
  );
};

exports.createSale = async (data) => {
  const errors = validateSale(data);
  if (errors.length > 0) throw new Error(errors.join(", "));

  // 1️⃣ Calculate total amount
  let total_amount = 0;
  data.items.forEach((i) => (total_amount += i.quantity * i.unit_price));

  // 2️⃣ Create main sale row
  const sale = await repo.createSale({
    salesperson_id: data.salesperson_id,
    customer_id: data.customer_id,
    total_amount,
    payment_status: "unpaid"
  });

  // 2.1️⃣ Insert into sale_balance (needed for payments module)
await db.query(
  `INSERT INTO sale_balance (sale_id, total_amount, paid_amount, balance)
   VALUES ($1, $2, 0, $2)`,
  [sale.id, total_amount]
);


  // 3️⃣ Insert sale items + reduce stock
  for (const item of data.items) {
    await repo.addSaleItem(sale.id, item);
    await reduceStock(item.product_id, item.quantity);
  }

  return sale;
};

exports.getSale = async (id) => {
  return await repo.getSaleById(id);
};

exports.getAllSales = async () => {
  return await repo.getAllSales();
};
