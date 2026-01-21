// src/api/settings/settings.controller.js

const service = require("./settings.service");

async function getCompanySettings(req, res, next) {
  try {
    const settings = await service.getSettings(req.db);
    res.json(settings);
  } catch (err) {
    next(err);
  }
}

async function saveCompanySettings(req, res, next) {
  try {
    const saved = await service.saveSettings(req.db, req.body);
    res.json({
      message: "Company settings saved successfully",
      data: saved
    });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  getCompanySettings,
  saveCompanySettings
};
