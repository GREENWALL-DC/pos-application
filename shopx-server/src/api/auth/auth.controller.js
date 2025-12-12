const asyncHandler = require("express-async-handler");
const service = require("./auth.service");

const registerUser = asyncHandler(async (req, res) => {
  const user = await service.register(req.body, req.user);  // <-- Pass req.user
  res.status(201).json({ message: "User registered successfully", user });
});


const loginUser = asyncHandler(async (req, res) => {
  const result = await service.login(req.body);
  res.json(result);
});

const loginAdmin = asyncHandler(async (req, res) => {
  const result = await service.loginAdmin(req.body);
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
  res.json({
    message: "User deleted successfully by admin",
    deleted_user: deleted,
  });
});

const getAllUsers = asyncHandler(async (req, res) => {
  const users = await service.getAllUsers();
  res.json({ message: "All users fetched successfully", users });
});

const loginOwner = asyncHandler(async (req, res) => {
  const result = await service.loginOwner(req.body);
  res.json(result);
});

const sendOTP = asyncHandler(async (req, res) => {
  const userId = req.user.id; // now ALWAYS available
  const { method } = req.body;

  const result = await service.sendOTP({ userId, method });
  res.json(result);
});

const verifyOTP = asyncHandler(async (req, res) => {
  const userId = req.user.id; // works for both normal & tempToken
  const { otp } = req.body;

  const result = await service.verifyOTP({ userId, otp });
  res.json(result);
});


module.exports = {
  registerUser,
  loginUser,
  loginAdmin,
  currentUser,
  updateUser,
  getUserById,
  deleteUser,
  deleteUserByAdmin,
  getAllUsers,
  loginOwner,
  sendOTP,
  verifyOTP,
};
