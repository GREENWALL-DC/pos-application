module.exports = async (client) => {
  try {
    // 1️⃣ Check if table exists
    const check = await client.query(`
      SELECT to_regclass('public.sales') AS table_name;
    `);

    if (check.rows[0].table_name !== null) {
      console.log('ℹ️ "sales" table already exists.');
      return;
    }

    // 2️⃣ Create table
    await client.query(`
      CREATE TABLE sales (
        id SERIAL PRIMARY KEY,
        customer_id INTEGER REFERENCES customers(id) ON DELETE SET NULL,
        salesperson_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
        total_amount NUMERIC(12,2) NOT NULL,
        payment_status VARCHAR(20) DEFAULT 'paid', 
        sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    console.log('✅ "sales" table created successfully.');
  } catch (err) {
    console.error('❌ Failed to create "sales" table:', err.message);
    throw err;
  }
};
