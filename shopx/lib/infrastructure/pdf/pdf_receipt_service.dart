import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shopx/domain/reciept/receipt_data.dart';

class PdfReceiptService {
  static Future<File> generateReceiptPdf(ReceiptData receipt) async {
    final pdf = pw.Document();

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
                // ---------------- HEADER ----------------
                pw.Text(
                  receipt.companyNameAr,
                  style: pw.TextStyle(
                    font: arabicFontBold,
                    fontSize: 18,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  receipt.companyNameEn,
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 12,
                  ),
                  textAlign: pw.TextAlign.center,
                ),

                pw.Divider(),

                // ---------------- COMPANY INFO ----------------
                _row(arabicFont, 'الرقم الضريبي', receipt.vatNumber),
                _row(arabicFont, 'السجل التجاري', receipt.crNumber),
                _row(arabicFont, 'المدينة', receipt.city),

                pw.SizedBox(height: 16),

                // ---------------- INVOICE INFO ----------------
                _row(arabicFont, 'رقم الفاتورة', receipt.invoiceNumber),
                _row(
                  arabicFont,
                  'تاريخ الفاتورة',
                  receipt.invoiceDate.toString(),
                ),
                _row(arabicFont, 'اسم العميل', receipt.customerName),

                pw.SizedBox(height: 16),

                // ---------------- ITEMS TABLE ----------------
                pw.Table.fromTextArray(
                  headers: [
                    'الصنف',
                    'الكمية',
                    'السعر',
                    'الإجمالي',
                  ],
                  data: receipt.items.map((item) {
                    return [
                      item.nameEn,
                      item.quantity.toString(),
                      item.unitPrice.toStringAsFixed(2),
                      (item.unitPrice * item.quantity)
                          .toStringAsFixed(2),
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(
                    font: arabicFontBold,
                  ),
                  cellStyle: pw.TextStyle(
                    font: arabicFont,
                  ),
                  cellAlignment: pw.Alignment.center,
                ),

                pw.SizedBox(height: 16),

                // ---------------- TOTALS ----------------
                _row(
                  arabicFont,
                  'الإجمالي الفرعي',
                  receipt.subTotal.toStringAsFixed(2),
                ),
                _row(
                  arabicFont,
                  'الضريبة (${receipt.vatPercentage}%)',
                  receipt.vatAmount.toStringAsFixed(2),
                ),
                pw.Divider(),
                _row(
                  arabicFontBold,
                  'الإجمالي النهائي',
                  receipt.netTotal.toStringAsFixed(2),
                ),

                pw.SizedBox(height: 24),

                // ---------------- QR ----------------
                pw.Center(
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: receipt.qrPayload,
                    width: 120,
                    height: 120,
                  ),
                ),

                pw.SizedBox(height: 16),

                pw.Text(
                  'شكراً لتعاملكم معنا',
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 12,
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

  static pw.Widget _row(
    pw.Font font,
    String label,
    String value,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(font: font)),
        pw.Text(value, style: pw.TextStyle(font: font)),
      ],
    );
  }
}
