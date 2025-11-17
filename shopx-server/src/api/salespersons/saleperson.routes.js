const express = require("express");
const router = express.Router();
const controller = require("./saleperson.controller");
const validateToken = require("../../middleware/validateTokenHandler");
const checkAdmin = require("../../middleware/checkAdmin");

// Admin only
router.post("/", validateToken, checkAdmin, controller.create);
router.get("/", validateToken, checkAdmin, controller.getAll);
router.get("/:id", validateToken, checkAdmin, controller.getOne);
router.put("/:id", validateToken, checkAdmin, controller.update);
router.delete("/:id", validateToken, checkAdmin, controller.remove);

module.exports = router;
