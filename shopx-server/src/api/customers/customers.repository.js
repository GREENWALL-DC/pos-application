const db = require("../../config/db");

exports.createCustomer = async ({ name, phone, address, gst_number }) => {
  const result = await db.query(
    `INSERT INTO customers (name, phone, address, gst_number)
VALUES ($1, $2, $3, $4)
 RETURNING *`,
    [name, phone, address, gst_number]
  );

  return result.rows[0];
};

exports.getAllCustomers = async () => {
  const result = await db.query(`SELECT * FROM customers ORDER BY id ASC`);
  return result.rows;
};

exports.getCustomerById = async (id) => {
  const result = await db.query(`SELECT * FROM customers WHERE id = $1`, [id]);
  return result.rows[0];
};

exports.updateCustomer = async (id, { name, phone, address, gst_number }) => {
  const result = await db.query(
    `UPDATE customers
     SET name = COALESCE($1,name),
         phone = COALESCE($2,phone),
         address = COALESCE($3,address),
          gst_number = COALESCE($4, gst_number),
         updated_at = CURRENT_TIMESTAMP
     WHERE id = $5
     RETURNING *`,
    [name, phone, address, gst_number, id]
  );

  return result.rows[0];
};

exports.deleteCustomer = async (id) => {
  const result = await db.query(
    `DELETE FROM customers WHERE id = $1 RETURNING *`,
    [id]
  );
  return result.rows[0];
};
