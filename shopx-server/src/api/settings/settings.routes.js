// src/api/settings/settings.routes.js

const express = require("express");
const router = express.Router();
const controller = require("./settings.controller");
const upload = require("../../middleware/uploadProductImage");
// const { validateCompanySettings } = require("./settings.validator");
// const isAdmin = require("../middlewares/isAdmin");

// POS + Admin
router.get("/", controller.getCompanySettings);

// Admin only (recommended)
router.post(
  "/",
  // isAdmin,
  // validateCompanySettings,
  controller.saveCompanySettings,
);
// Upload company logo
router.post("/logo", upload.single("logo"), async (req, res, next) => {
  try {
    // File is saved in uploads/products by multer
    const logoUrl = `/uploads/products/${req.file.filename}`;
    res.json({ logoUrl });
  } catch (err) {
    next(err);
  }
});


module.exports = router;
