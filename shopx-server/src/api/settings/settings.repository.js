// src/api/settings/settings.repository.js

async function getCompanySettings(client) {
  const result = await client.query(`SELECT * FROM company_settings LIMIT 1`);
  return result.rows[0] || null;
}

async function insertCompanySettings(client, data) {
  await client.query(
    `
    INSERT INTO company_settings (
      company_name_en,
      company_name_ar,
      company_address_en,
      company_address_ar,
      vat_number,
      cr_number,
      phone,
      email,
      account_number,
      iban,
      logo_url
    )
    VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
    `,
    [
      data.companyNameEn,
      data.companyNameAr,
      data.companyAddressEn,
      data.companyAddressAr,
      data.vatNumber,
      data.crNumber,
      data.phone,
      data.email,
      data.accountNumber,
      data.iban,
      data.logoUrl,
    ],
  );
}

async function updateCompanySettings(client, id, data) {
  await client.query(
    `
    UPDATE company_settings SET
      company_name_en=$1,
      company_name_ar=$2,
      company_address_en=$3,
      company_address_ar=$4,
      vat_number=$5,
      cr_number=$6,
      phone=$7,
      email=$8,
      account_number=$9,
      iban=$10,
      logo_url=$11,
      updated_at=NOW()
    WHERE id=$12
    `,
    [
      data.companyNameEn,
      data.companyNameAr,
      data.companyAddressEn,
      data.companyAddressAr,
      data.vatNumber,
      data.crNumber,
      data.phone,
      data.email,
      data.accountNumber,
      data.iban,
      data.logoUrl,
      id,
    ],
  );
}

module.exports = {
  getCompanySettings,
  insertCompanySettings,
  updateCompanySettings,
};
