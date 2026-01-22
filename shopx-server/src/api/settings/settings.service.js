const repo = require("./settings.repository");

async function getSettings() {
  return await repo.getCompanySettings();
}

async function saveSettings(data) {
  const existing = await repo.getCompanySettings();

  if (!existing) {
    await repo.insertCompanySettings(data);
  } else {
    await repo.updateCompanySettings(existing.id, data);
  }

  return await repo.getCompanySettings();
}

module.exports = {
  getSettings,
  saveSettings
};
