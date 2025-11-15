module.exports = async (client) => {
  try {
    // 1️⃣ Check if table exists
    const check = await client.query(`
      SELECT to_regclass('public.sale_items') AS table_name;
    `);

    if (check.rows[0].table_name !== null) {
      console.log('ℹ️ "sale_items" table already exists.');
      return;
    }

    // 2️⃣ Create table
    await client.query(`
      CREATE TABLE sale_items (
        id SERIAL PRIMARY KEY,
        sale_id INTEGER NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
        product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
        quantity INTEGER NOT NULL,
        price NUMERIC(10,2) NOT NULL,
        total NUMERIC(12,2) GENERATED ALWAYS AS (quantity * price) STORED
      );
    `);

    console.log('✅ "sale_items" table created successfully.');
  } catch (err) {
    console.error('❌ Failed to create "sale_items" table:', err.message);
    throw err;
  }
};
/*This allows:

✔ Thermal Bill

Because invoice = sale header + all sale_items

✔ Stock Deduction

quantity reduces from stock table

✔ Reports

“Top selling products”

“Total items sold today”

“Salesperson product performance”

“Product-wise sales in a period”

✔ Admin Analytics

All graphs & reports use this table. */