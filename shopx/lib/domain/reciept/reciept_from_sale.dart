// for  admin and user transaction od print preview screen that it for helper no other use 
import 'package:shopx/domain/config/company_config.dart';
import 'package:shopx/domain/reciept/receipt_data.dart';
import 'package:shopx/domain/sales/sale.dart';
import 'package:shopx/domain/settings/company_settings.dart';

ReceiptData receiptFromSale(
  Sale sale,
  CompanySettings company,
  ) {
  final receiptItems = sale.items.map((item) {
    return ReceiptItem(
      nameEn: item.productName,
      nameAr: item.productNameAr,
      unitPrice: item.unitPrice,
      quantity: item.quantity,
    );
  }).toList();

  return ReceiptData(
    companyNameEn: company.companyNameEn,
    companyNameAr: company.companyNameAr,
    // city: CompanyConfig.city,
    // country: CompanyConfig.country,
    crNumber: company.crNumber,
    vatNumber: company.vatNumber,
    mobile: company.phone,

    invoiceNumber: sale.id.toString(),
    invoiceDate: sale.saleDate,
    customerName: sale.customerName,
    customerVat: sale.customerTin,  // ✅ ADD THIS LINE

    items: receiptItems,
    subTotal: sale.subtotalAmount,
    discount: sale.discountAmount,
    vatPercentage: sale.vatPercentage,
    vatAmount: sale.vatAmount,
    netTotal: sale.totalAmount,

    qrPayload: 'Invoice:${sale.id}',
  );
}
