// src/api/settings/settings.routes.js

const express = require("express");
const router = express.Router();
const controller = require("./settings.controller");

// Admin only (add auth middleware if you already use it)
router.get("/", controller.getCompanySettings);
router.post("/", controller.saveCompanySettings);

module.exports = router;
