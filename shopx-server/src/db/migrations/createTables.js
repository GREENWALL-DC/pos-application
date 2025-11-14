const  pool  = require("../../config/db");
const createUsersTable = require("./tables/users.tables");

const createTables = async () => {
  const client = await pool.connect();

  try {
    console.log("🚀 Running migrations...");

    await createUsersTable(client);

    console.log("✅ All tables created successfully!");
  } catch (err) {
    console.error("❌ Migration failed:", err);
    process.exit(1);
  } finally {
    client.release();
  }
};

// We export createTables so migrate.js or server.js can use it.
module.exports = createTables;
