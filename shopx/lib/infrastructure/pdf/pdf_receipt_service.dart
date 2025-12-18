import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shopx/domain/reciept/receipt_data.dart';

class PdfReceiptService {
  static Future<File> generateReceiptPdf(ReceiptData receipt) async {
    final pdf = pw.Document();

    // Arabic fonts
    final arabicFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Cairo-Regular.ttf'),
    );
    final arabicFontBold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Cairo-Bold.ttf'),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [

                // =========================================================
                // HEADER + COMPANY + INVOICE INFO (ONE TABLE)
                // =========================================================
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(3),
                    2: const pw.FlexColumnWidth(2),
                    3: const pw.FlexColumnWidth(3),
                  },
                  children: [
                    _infoRow(
                      arabicFontBold,
                      'Vendor',
                      receipt.companyNameEn,
                      'اسم المورد',
                      receipt.companyNameAr,
                    ),
                    _infoRow(
                      arabicFont,
                      'VAT No.',
                      receipt.vatNumber,
                      'الرقم الضريبي',
                      receipt.vatNumber,
                    ),
                    _infoRow(
                      arabicFont,
                      'CR No.',
                      receipt.crNumber,
                      'السجل التجاري',
                      receipt.crNumber,
                    ),
                    _infoRow(
                      arabicFont,
                      'Invoice No.',
                      receipt.invoiceNumber,
                      'رقم الفاتورة',
                      receipt.invoiceNumber,
                    ),
                    _infoRow(
                      arabicFont,
                      'Invoice Date',
                      receipt.invoiceDate
                          .toString()
                          .split(' ')
                          .first,
                      'تاريخ الفاتورة',
                      receipt.invoiceDate
                          .toString()
                          .split(' ')
                          .first,
                    ),
                    _infoRow(
                      arabicFont,
                      'Customer',
                      receipt.customerName,
                      'اسم العميل',
                      receipt.customerName,
                    ),
                  ],
                ),

                pw.SizedBox(height: 16),

                // =========================================================
                // ITEMS TABLE
                // =========================================================
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: const pw.FixedColumnWidth(30), // S.No
                    1: const pw.FlexColumnWidth(3),  // Description
                    2: const pw.FixedColumnWidth(50), // Qty
                    3: const pw.FixedColumnWidth(60), // Price
                    4: const pw.FixedColumnWidth(50), // VAT
                    5: const pw.FixedColumnWidth(70), // Amount
                  },
                  children: [
                    // Header
                    pw.TableRow(
                      decoration:
                          const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        _cell(arabicFontBold, 'S'),
                        _cell(arabicFontBold, 'Description'),
                        _cell(arabicFontBold, 'Qty'),
                        _cell(arabicFontBold, 'Price'),
                        _cell(arabicFontBold, 'VAT'),
                        _cell(arabicFontBold, 'Amount'),
                      ],
                    ),

                    // Items
                    ...List.generate(receipt.items.length, (index) {
                      final item = receipt.items[index];
                      final total = item.unitPrice * item.quantity;
                      final vat =
                          total * receipt.vatPercentage / 100;

                      return pw.TableRow(
                        children: [
                          _cell(arabicFont, '${index + 1}'),
                          _cell(arabicFont, item.nameEn),
                          _cell(arabicFont, item.quantity.toString()),
                          _cell(
                              arabicFont,
                              item.unitPrice
                                  .toStringAsFixed(2)),
                          _cell(
                              arabicFont,
                              vat.toStringAsFixed(2)),
                          _cell(
                              arabicFont,
                              total.toStringAsFixed(2)),
                        ],
                      );
                    }),
                  ],
                ),

                pw.SizedBox(height: 16),

                // =========================================================
                // TOTALS + QR
                // =========================================================
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // QR
                    pw.Expanded(
                      child: pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: receipt.qrPayload,
                        width: 110,
                        height: 110,
                      ),
                    ),

                    // Totals
                    pw.Expanded(
                      child: pw.Table(
                        border: pw.TableBorder.all(),
                        children: [
                          _totalRow(
                            arabicFont,
                            'Taxable Amount',
                            receipt.subTotal,
                          ),
                          _totalRow(
                            arabicFont,
                            'Discount',
                            0,
                          ),
                          _totalRow(
                            arabicFont,
                            'Amount After Discount',
                            receipt.subTotal,
                          ),
                          _totalRow(
                            arabicFont,
                            'VAT ${receipt.vatPercentage}%',
                            receipt.vatAmount,
                          ),
                          _totalRow(
                            arabicFontBold,
                            'Total Amount with VAT',
                            receipt.netTotal,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 24),

                // =========================================================
                // SIGNATURES
                // =========================================================
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      children: [
                        _cell(arabicFont, 'Salesman'),
                        _cell(arabicFont, 'Approved by'),
                        _cell(arabicFont, 'Received by'),
                        _cell(arabicFont, 'Customer Signature'),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        _cell(arabicFont, ''),
                        _cell(arabicFont, ''),
                        _cell(arabicFont, ''),
                        _cell(arabicFont, ''),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 16),

                pw.Text(
                  'شكراً لتعاملكم معنا',
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 11,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final file =
        File('${dir.path}/invoice_${receipt.invoiceNumber}.pdf');

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // =========================================================
  // HELPERS
  // =========================================================

  static pw.TableRow _infoRow(
    pw.Font font,
    String enLabel,
    String enValue,
    String arLabel,
    String arValue,
  ) {
    return pw.TableRow(
      children: [
        _cell(font, enLabel),
        _cell(font, enValue),
        _cell(font, arLabel),
        _cell(font, arValue),
      ],
    );
  }

  static pw.Widget _cell(pw.Font font, String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: 9),
      ),
    );
  }

  static pw.TableRow _totalRow(
    pw.Font font,
    String label,
    double value,
  ) {
    return pw.TableRow(
      children: [
        _cell(font, label),
        _cell(font, value.toStringAsFixed(2)),
      ],
    );
  }
}
