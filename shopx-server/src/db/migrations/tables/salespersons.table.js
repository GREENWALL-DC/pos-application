module.exports = async (client) => {
  try {
    const check = await client.query(`
      SELECT to_regclass('public.salespersons') AS table_name;
    `);

    if (check.rows[0].table_name) {
      console.log('ℹ️ "salespersons" table already exists.');
      return;
    }

    await client.query(`
      CREATE TABLE salespersons (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        phone VARCHAR(20) UNIQUE NOT NULL,
        address TEXT,
        joining_date DATE DEFAULT CURRENT_DATE,
        status VARCHAR(20) DEFAULT 'active'
      );
    `);

    console.log('✅ "salespersons" table created successfully.');
  } catch (err) {
    console.error('❌ Failed to create "salespersons" table:', err.message);
    throw err;
  }
};
