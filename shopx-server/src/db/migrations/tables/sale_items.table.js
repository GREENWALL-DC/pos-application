module.exports = async (client) => {
  try {
    const check = await client.query(`
      SELECT to_regclass('public.sale_items') AS table_name;
    `);

    if (check.rows[0].table_name) {
      console.log('ℹ️ "sale_items" table already exists.');
      return;
    }

    await client.query(`
      CREATE TABLE sale_items (
        id SERIAL PRIMARY KEY,
        sale_id INTEGER REFERENCES sales(id) ON DELETE CASCADE,
        product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
        quantity INTEGER NOT NULL,
        fulfilled_quantity INTEGER NOT NULL DEFAULT 0,  -- 👈 NEW
        unit_price NUMERIC(10,2) NOT NULL,
        total_price NUMERIC(10,2) NOT NULL,
         discount NUMERIC(10,2) DEFAULT 0 
      );
    `);

    console.log('✅ "sale_items" table created.');
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