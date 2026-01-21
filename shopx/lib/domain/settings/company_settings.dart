class CompanySettings {
  final int id;

  final String companyNameEn;
  final String companyNameAr;

  // ✅ REQUIRED – bilingual address
  final String companyAddressEn;
  final String companyAddressAr;

  final String vatNumber;
  final String crNumber;

  // optional
  final String? phone;
  final String? email;
  final String? accountNumber;
  final String? iban;
  final String? logoUrl;

  final DateTime createdAt;

  CompanySettings({
    required this.id,
    required this.companyNameEn,
    required this.companyNameAr,
    required this.companyAddressEn,
    required this.companyAddressAr,
    required this.vatNumber,
    required this.crNumber,
    this.phone,
    this.email,
    this.accountNumber,
    this.iban,
    this.logoUrl,
    required this.createdAt,
  });

  factory CompanySettings.fromJson(Map<String, dynamic> json) {
    return CompanySettings(
      id: json['id'],
      companyNameEn: json['company_name_en'],
      companyNameAr: json['company_name_ar'],
      companyAddressEn: json['company_address_en'],
      companyAddressAr: json['company_address_ar'],
      vatNumber: json['vat_number'],
      crNumber: json['cr_number'],
      phone: json['phone'],
      email: json['email'],
      accountNumber: json['account_number'],
      iban: json['iban'],
      logoUrl: json['logo_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_name_en': companyNameEn,
      'company_name_ar': companyNameAr,
      'company_address_en': companyAddressEn,
      'company_address_ar': companyAddressAr,
      'vat_number': vatNumber,
      'cr_number': crNumber,
      'phone': phone,
      'email': email,
      'account_number': accountNumber,
      'iban': iban,
      'logo_url': logoUrl,
    };
  }
}
