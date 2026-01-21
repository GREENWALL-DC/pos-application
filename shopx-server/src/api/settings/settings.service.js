// src/api/settings/settings.service.js

const repo = require("./settings.repository");

async function getSettings(client) {
  const settings = await repo.getCompanySettings(client);

  // Ensure company settings always exist for POS flow
  if (!settings) {
    const defaultSettings = {
      companyNameEn: "",
      companyNameAr: "",
      companyAddressEn: "",
      companyAddressAr: "",
      vatNumber: "",
      crNumber: "",
      phone: null,
      email: null,
      accountNumber: null,
      iban: null,
      logoUrl: null,
    };

    await repo.insertCompanySettings(client, defaultSettings);
    return await repo.getCompanySettings(client);
  }

  return settings;
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
