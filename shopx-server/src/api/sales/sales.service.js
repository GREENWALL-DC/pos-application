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

    // 2️⃣ CALCULATE SUBTOTAL

    const VAT_PERCENTAGE = 15;

    // 1️⃣ GROSS SUBTOTAL (NO ITEM DISCOUNT)
    let gross_subtotal = 0;
    data.items.forEach((i) => {
      gross_subtotal += i.quantity * i.unit_price;
    });

    // 2️⃣ SALE-LEVEL DISCOUNT
    const discount_amount = Number(data.discount_amount || 0);

    if (discount_amount < 0) {
      throw new Error("Discount cannot be negative");
    }

    if (discount_amount > gross_subtotal) {
      throw new Error("Discount cannot exceed subtotal");
    }

    // // 3️⃣ TAXABLE AMOUNT
    // const taxable_amount = gross_subtotal - discount_amount;

    // // 4️⃣ VAT
    // const vat_amount = taxable_amount * (VAT_PERCENTAGE / 100);

    // // 5️⃣ FINAL TOTAL
    // const total_amount = taxable_amount + vat_amount;

    

// 3️⃣ VAT — CALCULATED ON GROSS SUBTOTAL (DISCOUNT DOES NOT AFFECT VAT)
const vat_amount = +(gross_subtotal * (VAT_PERCENTAGE / 100)).toFixed(2);

// 4️⃣ FINAL TOTAL = SUBTOTAL + VAT - DISCOUNT
const total_amount = +(
  gross_subtotal +
  vat_amount -
  discount_amount
).toFixed(2);

// Safety check
if (total_amount < 0) {
  throw new Error("Total amount cannot be negative");
}




    // 3️⃣ CREATE MAIN SALE
    const sale = await repo.createSale(client, {
      salesperson_id: data.salesperson_id,
      customer_id: data.customer_id,
      subtotal_amount: gross_subtotal,
      discount_amount,
      vat_percentage: VAT_PERCENTAGE,
      vat_amount,
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

      // // Deduct only fulfilled quantity
      // if (fulfillQty > 0) {
      //   await stockService.adjustStock(item.product_id, -fulfillQty, "sale");
      // }

      // Deduct FULL sold quantity (allow negative stock)
      await stockService.adjustStock(item.product_id, -item.quantity, "sale");

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
