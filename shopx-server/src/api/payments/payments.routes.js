const express = require("express");
const router = express.Router();

const controller = require("./payments.controller");
const { addPaymentValidator } = require("./payments.validators");
const validateToken = require("../../middleware/validateTokenHandler");

router.post("/", validateToken, addPaymentValidator, controller.addPayment);
router.get("/:saleId", validateToken, controller.getPayments);

module.exports = router;
