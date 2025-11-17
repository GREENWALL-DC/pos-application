const db = require("../../config/db");

exports.createSalesperson = async ({ name, phone, address }) => {
  const result = await db.query(
    `INSERT INTO salespersons (name, phone, address)
     VALUES ($1, $2, $3)
     RETURNING *`,
    [name, phone, address]
  );

  return result.rows[0];
};

exports.findAll = async () => {
  const result = await db.query(`SELECT * FROM salespersons ORDER BY id ASC`);
  return result.rows;
};

exports.findById = async (id) => {
  const result = await db.query(
    `SELECT * FROM salespersons WHERE id = $1`,
    [id]
  );
  return result.rows[0];
};

exports.updateSalesperson = async (id, { name, phone, address, status }) => {
  const result = await db.query(
    `UPDATE salespersons
     SET name = COALESCE($1, name),
         phone = COALESCE($2, phone),
         address = COALESCE($3, address),
         status = COALESCE($4, status),
         joining_date = joining_date
     WHERE id = $5
     RETURNING *`,
    [name, phone, address, status, id]
  );

  return result.rows[0];
};

exports.deleteSalesperson = async (id) => {
  const result = await db.query(
    `DELETE FROM salespersons WHERE id = $1 RETURNING *`,
    [id]
  );
  return result.rows[0];
};