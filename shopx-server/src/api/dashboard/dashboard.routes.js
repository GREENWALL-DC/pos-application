const express = require("express");
const router = express.Router();

const controller = require("./dashboard.controller");
const validateToken = require("../../middleware/validateTokenHandler");
const checkAdmin = require("../../middleware/checkAdmin");

// Only admin can view dashboard
router.get("/", validateToken, checkAdmin, controller.getDashboard);


// 📊 Sales chart
router.get(
  "/sales-chart",
  validateToken,
  checkAdmin,
  controller.getSalesChart
);

module.exports = router;
