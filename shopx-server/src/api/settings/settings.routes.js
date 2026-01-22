// src/api/settings/settings.routes.js

const express = require("express");
const router = express.Router();
const controller = require("./settings.controller");
// const { validateCompanySettings } = require("./settings.validator");
// const isAdmin = require("../middlewares/isAdmin");

// POS + Admin
router.get("/", controller.getCompanySettings);

// Admin only (recommended)
router.post(
  "/",
  // isAdmin,
  // validateCompanySettings,
  controller.saveCompanySettings
);

module.exports = router;
