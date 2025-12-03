const db = require("../../config/db");
const repo = require("./sales.repositary");

// For stock deduction
const stockRepo = require("../stock/stock.repository");

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
    data.items.forEach(i => total_amount += i.quantity * i.unit_price);

    // 3️⃣ CREATE MAIN SALE
    const sale = await repo.createSale(client, {
      salesperson_id: data.salesperson_id,
      customer_id: data.customer_id,
      total_amount,
    });

    // 4️⃣ CREATE SALE BALANCE ENTRY
    await repo.createSaleBalance(client, sale.id, total_amount);

    // 5️⃣ INSERT SALE ITEMS + REDUCE STOCK
    for (const item of data.items) {
      await repo.addSaleItem(client, sale.id, item);

      // reduce stock
      await stockRepo.updateStockQuantity(item.product_id, -item.quantity);
      await stockRepo.insertStockMovement(item.product_id, -item.quantity, "sale");
    }

    // 6️⃣ AUTO PAYMENT (FULL PAYMENT NOW)
    const payment = await paymentsRepo.createPayment({
      saleId: sale.id,
      customerId: data.customer_id,
      amount: total_amount,
      method: data.payment_method || "cash"
    });

    // 7️⃣ UPDATE BALANCE
    await paymentsRepo.updateSaleBalance({
      saleId: sale.id,
      paidAmount: total_amount,
      balance: 0,
    });

    // 8️⃣ SET SALE AS FULLY PAID
    await paymentsRepo.updateSaleStatus(sale.id, "paid");

    await client.query("COMMIT");

    return {
      sale,
      payment: payment.rows[0]
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
