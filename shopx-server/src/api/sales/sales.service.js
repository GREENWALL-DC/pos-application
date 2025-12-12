const db = require("../../config/db");
const repo = require("./sales.repositary");

// For stock deduction
// ✔ USE STOCK *SERVICE* — not repository!
const stockService = require("../stock/stock.service");

// For payments
const paymentsRepo = require("../payments/payments.repository");

exports.createSale = async (data) => {
  const client = await db.connect();

  try {
    await client.query("BEGIN");

    // 1️⃣ VALIDATE ITEMS
    if (!data.items || data.items.length === 0) {
      throw new Error("At least one item is required");
    }
    if (!data.customer_id) {
      throw new Error("Customer is required");
    }

    // 2️⃣ CALCULATE TOTAL
   let total_amount = 0;
data.items.forEach((i) => {
  const discount = i.discount || 0;
  total_amount += i.quantity * (i.unit_price - discount);
});


    // 3️⃣ CREATE MAIN SALE
    const sale = await repo.createSale(client, {
      salesperson_id: data.salesperson_id,
      customer_id: data.customer_id,
      total_amount,
    });

   // 5️⃣ INSERT SALE ITEMS + REDUCE STOCK (correct way)
for (const item of data.items) {
  await repo.addSaleItem(client, sale.id, item);

  // Use REAL stock logic (prevents negative stock, checks availability)
  await stockService.adjustStock(item.product_id, -item.quantity, "sale");
}


    // 6️⃣ CREATE ONE FULL PAYMENT
    const payment = await paymentsRepo.createPayment(client, {
      saleId: sale.id,
      customerId: data.customer_id,
      amount: total_amount, // always full
      method: data.payment_method || "cash",
    });

    // 7️⃣ SET SALE AS PAID
    await paymentsRepo.updateSaleStatus(sale.id, "paid");

    await client.query("COMMIT");

    return {
      sale,
      payment: payment.rows[0],
    };
  } catch (err) {
    await client.query("ROLLBACK");
    throw err;
  } finally {
    client.release();
  }
};

exports.getFullInvoice = async (id) => {
  return await repo.getFullInvoice(id);
};

exports.getAllSales = async () => {
  return await repo.getAllSales();
};
