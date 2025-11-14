const asyncHandler = require("express-async-handler");
const service = require("./auth.service");

const registerUser = asyncHandler(async (req, res) => {
  const user = await service.register(req.body);
  res.status(201).json({ message: "User registered successfully", user });
});

const loginUser = asyncHandler(async (req, res) => {
  const result = await service.login(req.body);
  res.json(result);
});

const currentUser = asyncHandler(async (req, res) => {
  res.json(req.user);
});

const updateUser = asyncHandler(async (req, res) => {
  const updated = await service.updateUser(req.user.id, req.body);
  res.json({ message: "User updated successfully", user: updated });
});

const getUserById = asyncHandler(async (req, res) => {
  const user = await service.getUserById(req.params.id);
  res.json(user);
});

const deleteUser = asyncHandler(async (req, res) => {
  await service.deleteSelf(req.user.id);
  res.json({ message: "User deleted successfully" });
});

const deleteUserByAdmin = asyncHandler(async (req, res) => {
  const deleted = await service.deleteUserByAdmin(req.params.id);
  res.json({ message: "User deleted successfully by admin", deleted_user: deleted });
});

const getAllUsers = asyncHandler(async (req, res) => {
  const users = await service.getAllUsers();
  res.json({ message: "All users fetched successfully", users });
});

module.exports = {
  registerUser,
  loginUser,
  currentUser,
  updateUser,
  getUserById,
  deleteUser,
  deleteUserByAdmin,
  getAllUsers,
};
