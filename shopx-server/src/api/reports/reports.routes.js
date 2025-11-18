const express = require("express");
const router = express.Router();
const controller = require("./reports.controller");
const validateToken = require("../../middleware/validateTokenHandler");
const checkAdmin = require("../../middleware/checkAdmin");

// Reports are admin-level (you can allow salesperson too for some)
router.get("/daily", validateToken, checkAdmin, controller.dailySales);
router.get("/monthly", validateToken, checkAdmin, controller.monthlySales);

// Salesperson own reports (no admin check)
router.get("/my/daily", validateToken, controller.myDailySales);
router.get("/my/monthly", validateToken, controller.myMonthlySales);


router.get("/salesperson", validateToken, checkAdmin, controller.salesBySalesperson);
router.get("/products", validateToken, checkAdmin, controller.productSales);
router.get("/customer-ledger/:customerId", validateToken, checkAdmin, controller.customerLedger);
router.get("/outstanding", validateToken, checkAdmin, controller.outstandingByCustomer);

module.exports = router;
