const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const repo = require("./auth.repository");

const register = async ({ username, email, password, user_type }) => {
  if (!username || !email || !password) {
    throw new Error("ALL fields are mandatory");
  }

  const existing = await repo.findUserByEmail(email);
  if (existing) throw new Error("User Already Registered!");

  const passwordHash = await bcrypt.hash(password, 10);

  const user = await repo.createUser({
    username,
    email,
    passwordHash,
    user_type: user_type || "salesperson",
  });

  return {
    id: user.id,
    username: user.username,
    email: user.email,
    user_type: user.user_type,
  };
};

const login = async ({ username, password }) => {
  if (!username || !password) throw new Error("All fields are Mandatory");

  const user = await repo.findUserByUsername(username);
  if (!user) throw new Error("Invalid credentials");

  const match = await bcrypt.compare(password, user.password);
  if (!match) throw new Error("Invalid credentials");

  const accessToken = jwt.sign(
    {
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        user_type: user.user_type,
      },
    },
    process.env.ACCESS_TOKEN_SECRET,
    { expiresIn: "1d" }
  );

  return { accessToken };
};

const updateUser = async (userId, { username, email }) => {
  if (!username && !email) throw new Error("Provide username or email");

  if (email) {
    const check = await repo.findUserByEmail(email);
    if (check && check.id !== userId) throw new Error("Email already in use");
  }

  const updated = await repo.updateUser(userId, username, email);
  if (!updated) throw new Error("User not found");

  return updated;
};

const getUserById = async (id) => {
  const user = await repo.findUserById(id);
  if (!user) throw new Error("User not found");
  return user;
};

const deleteSelf = async (userId) => {
  const deleted = await repo.deleteUserById(userId);
  if (!deleted) throw new Error("User not found");
};

const deleteUserByAdmin = async (id) => {
  const deleted = await repo.deleteUserById(id);
  if (!deleted) throw new Error("User not found");
  return deleted;
};

const getAllUsers = async () => {
  return await repo.getAllUsers();
};

module.exports = {
  register,
  login,
  updateUser,
  getUserById,
  deleteSelf,
  deleteUserByAdmin,
  getAllUsers,
};
