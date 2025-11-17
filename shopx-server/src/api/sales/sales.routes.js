const express = require("express");
const router = express.Router();
const controller = require("./sales.controller");
const validateToken = require("../../middleware/validateTokenHandler");

router.post("/", validateToken, controller.createSale);
router.get("/", validateToken, controller.getAllSales);
router.get("/:id", validateToken, controller.getSaleById);

module.exports = router;
