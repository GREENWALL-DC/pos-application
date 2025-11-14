const express = require("express");
const controller = require("./auth.controller");
const validateToken = require("../../middleware/validateTokenHandler");
const checkAdmin = require("../../middleware/checkAdmin");
const { registerValidator, loginValidator } = require("./auth.validator");

const router = express.Router();

// Public
router.post("/register", registerValidator, controller.registerUser);
router.post("/login", loginValidator, controller.loginUser);

// Protected
router.get("/current", validateToken, controller.currentUser);
router.put("/update", validateToken, controller.updateUser);
router.delete("/delete", validateToken, controller.deleteUser);

// Admin
router.get("/users", validateToken, checkAdmin, controller.getAllUsers);
router.get("/user/:id", validateToken, checkAdmin, controller.getUserById);
router.delete("/user/:id", validateToken, checkAdmin, controller.deleteUserByAdmin);

module.exports = router;
