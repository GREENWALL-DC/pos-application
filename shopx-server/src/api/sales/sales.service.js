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

    let isBackorder = false;

    // 5️⃣ INSERT SALE ITEMS
    for (const item of data.items) {
      const stock = await stockService.getStock(item.product_id);
      const availableQty = stock?.quantity || 0;

      // Fulfill only what is available
      const fulfillQty = Math.min(availableQty, item.quantity);
      const pendingQty = item.quantity - fulfillQty;

      // Insert sale item with fulfilled_quantity
      await client.query(
        `INSERT INTO sale_items 
     (sale_id, product_id, quantity, fulfilled_quantity, unit_price, discount, total_price)
     VALUES ($1, $2, $3, $4, $5, $6, $7)`,
        [
          sale.id,
          item.product_id,
          item.quantity,
          fulfillQty,
          item.unit_price,
          item.discount || 0,
          item.quantity * (item.unit_price - (item.discount || 0)),
        ]
      );

      // Deduct only fulfilled quantity
      if (fulfillQty > 0) {
        await stockService.adjustStock(item.product_id, -fulfillQty, "sale");
      }

      // If anything pending → backorder
      if (pendingQty > 0) {
        isBackorder = true;
      }
    }

    // 6️⃣ UPDATE SALE STATUS (FINAL & ONLY PLACE)
    const saleStatus = isBackorder ? "backorder" : "completed";
    await repo.updateSaleStatus(client, sale.id, saleStatus);

    // 7️⃣ CREATE ONE FULL PAYMENT (ALWAYS PAID – CLIENT RULE)
    const payment = await paymentsRepo.createPayment(client, {
      saleId: sale.id,
      customerId: data.customer_id,

      amount: total_amount, // always full
      method: data.payment_method || "cash",
    });

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
