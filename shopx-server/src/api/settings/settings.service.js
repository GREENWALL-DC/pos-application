// src/api/settings/settings.service.js

const repo = require("./settings.repository");

async function getSettings(client) {
  return await repo.getCompanySettings(client);
}

async function saveSettings(client, data) {
  const existing = await repo.getCompanySettings(client);

  if (!existing) {
    await repo.insertCompanySettings(client, data);
  } else {
    await repo.updateCompanySettings(client, existing.id, data);
  }

  return await repo.getCompanySettings(client);
}

module.exports = {
  getSettings,
  saveSettings
};
