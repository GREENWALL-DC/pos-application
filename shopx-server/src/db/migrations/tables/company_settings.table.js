module.exports = async (client) => {
  try {
    await client.query(`
      CREATE TABLE IF NOT EXISTS company_settings (
        id SERIAL PRIMARY KEY,

        company_name_en VARCHAR(255) NOT NULL,
        company_name_ar VARCHAR(255) NOT NULL,

        company_address_en TEXT NOT NULL,
        company_address_ar TEXT NOT NULL,

        vat_number VARCHAR(50) NOT NULL,
        cr_number VARCHAR(50) NOT NULL,

        phone VARCHAR(30),
        email VARCHAR(255),

        account_number VARCHAR(100),
        iban VARCHAR(100),

        logo_url TEXT,

        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    console.log("✅ company_settings table created");
  } catch (err) {
    console.error("❌ Failed to create company_settings table", err);
    throw err;
  }
};
