const db = require("../../config/db");

// --- SELECT ---
const findUserByEmail = async (email) => {
  const r = await db.query("SELECT * FROM users WHERE email = $1", [email]);
  return r.rows[0] || null;
};

const findUserByUsername = async (username) => {
  const r = await db.query("SELECT * FROM users WHERE username = $1", [username]);
  return r.rows[0] || null;
};

const findUserById = async (id) => {
  const r = await db.query("SELECT id, username, email, user_type FROM users WHERE id = $1", [id]);
  return r.rows[0] || null;
};

const getAllUsers = async () => {
  const r = await db.query("SELECT id, username, email, user_type FROM users ORDER BY id ASC");
  return r.rows;
};

// --- INSERT ---
const createUser = async ({ username, email, passwordHash, user_type }) => {
  const r = await db.query(
    "INSERT INTO users (username, email, password, user_type) VALUES ($1,$2,$3,$4) RETURNING *",
    [username, email, passwordHash, user_type]
  );
  return r.rows[0];
};

// --- UPDATE ---
const updateUser = async (id, username, email) => {
  const r = await db.query(
    "UPDATE users SET username = COALESCE($1, username), email = COALESCE($2, email) WHERE id = $3 RETURNING id, username, email",
    [username, email, id]
  );
  return r.rows[0];
};

// --- DELETE ---
const deleteUserById = async (id) => {
  const r = await db.query("DELETE FROM users WHERE id = $1 RETURNING *", [id]);
  return r.rows[0] || null;
};

module.exports = {
  findUserByEmail,
  findUserByUsername,
  findUserById,
  getAllUsers,
  createUser,
  updateUser,
  deleteUserById,
};

