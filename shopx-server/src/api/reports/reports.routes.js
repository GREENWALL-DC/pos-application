const express = require("express");
const router = express.Router();
const controller = require("./reports.controller");
const validateToken = require("../../middleware/validateTokenHandler");
const checkAdmin = require("../../middleware/checkAdmin");

router.get("/summary", validateToken, checkAdmin, controller.summary);
router.get("/salesman", validateToken, checkAdmin, controller.salesman);
router.get("/products", validateToken, checkAdmin, controller.products);
router.get("/customers", validateToken, checkAdmin, controller.customers);


module.exports = router;
