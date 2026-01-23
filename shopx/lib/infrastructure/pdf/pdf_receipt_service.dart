/*
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shopx/domain/reciept/receipt_data.dart';

class CompanyFixedData {
  // ✅ OFFICIAL REGISTERED NAME
  static const companyNameEn = 'SAQAF NAQAL TRADING Est.';
  static const companyNameAr = 'مؤسسة سقاف النقل التجارية';

  // ✅ OPTIONAL BUSINESS DESCRIPTION (can be kept or removed)
  static const businessEn = 'MAKKAH - KSA';
  static const businessAr = 'مكة المكرمة - المملكة العربية السعودية';

  // ✅ OFFICIAL NUMBERS (FROM IMAGE)
  static const vatNumber = '310185723200003';
  static const crNumber = '4031213057';

  // OPTIONAL (used only if you want)
  // static const mobile = '0571830599';
}

class PdfReceiptService {
  static Future<File> generateReceiptPdf(ReceiptData receipt) async {
    final pdf = pw.Document();

    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Cairo-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Cairo-Bold.ttf'),
    );

    final logo = pw.MemoryImage(
      (await rootBundle.load(
        'assets/images/pdf_logo.png',
      )).buffer.asUint8List(),
    );

    final date = receipt.invoiceDate.toString().split(' ').first;

    final saleDate = receipt.invoiceDate;

    final invoiceDateFormatted =
        '${saleDate.day.toString().padLeft(2, '0')}, '
        '${saleDate.month.toString().padLeft(2, '0')}, '
        '${saleDate.year}';

    final deliveryDateFormatted =
        '${saleDate.year}-'
        '${saleDate.month.toString().padLeft(2, '0')}-'
        '${saleDate.day.toString().padLeft(2, '0')}';

    final qrData = _zatcaQr(
      sellerName: CompanyFixedData.companyNameEn,
      vatNumber: CompanyFixedData.vatNumber,
      invoiceDate: receipt.invoiceDate,
      totalWithVat: receipt.netTotal,
      vatAmount: receipt.vatAmount,
    );

    // const int minItemRows = 10;
    const double itemRowHeight = 18;
    const int minItemRows = 10;

    // ================= ITEMS LOGIC =================
    final itemRows = receipt.items.asMap().entries.map((e) {
      final i = e.key + 1;
      final item = e.value;
      final total = item.unitPrice * item.quantity;
      final vat = total * receipt.vatPercentage / 100;

      return pw.TableRow(
        children: [
          _cell(regular, '$i'),
          _cell(
            regular,
            item.nameAr?.isNotEmpty == true
                ? '${item.nameAr}\n${item.nameEn}'
                : item.nameEn,
          ),
          _cell(regular, item.quantity.toString()),
          _cell(regular, item.unitPrice.toStringAsFixed(2)),
          _cell(regular, vat.toStringAsFixed(2)),
          _cell(regular, total.toStringAsFixed(2)),
        ],
      );
    }).toList();

    // final int emptyRowCount = receipt.items.length < minItemRows
    //     ? minItemRows - receipt.items.length
    //     : 0;

    // final emptyRows = List.generate(
    //   emptyRowCount,
    //   (_) => pw.TableRow(children: List.generate(6, (_) => _cell(regular, ''))),
    // );

    final int visibleItemCount = receipt.items.length;
    final int remainingRows = visibleItemCount < minItemRows
        ? minItemRows - visibleItemCount
        : 0;

    final double blankHeight = remainingRows * itemRowHeight;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(16),
        build: (_) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // ================= HEADER (NO BOX) =================
              pw.Directionality(
                textDirection: pw.TextDirection.ltr,
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // LEFT — ENGLISH
                    pw.Expanded(
                      child: _headerBlock(
                        bold,
                        CompanyFixedData.companyNameEn,
                        CompanyFixedData.businessEn,
                        'VAT No: ${CompanyFixedData.vatNumber}\nCR No: ${CompanyFixedData.crNumber}',
                        pw.TextAlign.left,
                      ),
                    ),

                    pw.Center(child: pw.Image(logo, width: 75)),

                    // RIGHT — ARABIC
                    pw.Expanded(
                      child: _headerBlock(
                        bold,
                        CompanyFixedData.companyNameAr,
                        CompanyFixedData.businessAr,
                        'الرقم الضريبي: ${CompanyFixedData.vatNumber}\nالسجل التجاري: ${CompanyFixedData.crNumber}',
                        pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 10),

              // ================= BOX 1 & 2 : VENDOR + CUSTOMER =================
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(),
                  1: const pw.FlexColumnWidth(),
                },
                children: [
                  // TITLE ROW
                  pw.TableRow(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          'Tax Invoice  |  فاتورة ضريبية',
                          style: pw.TextStyle(font: bold, fontSize: 10),
                        ),
                      ),
                      pw.Container(),
                    ],
                  ),

                  // CONTENT ROW
                  pw.TableRow(
                    children: [
                      // LEFT COLUMN — VENDOR + INVOICE
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              CompanyFixedData.companyNameEn,
                              style: pw.TextStyle(font: bold, fontSize: 9),
                            ),
                            pw.Text(
                              CompanyFixedData.companyNameAr,
                              style: pw.TextStyle(font: regular, fontSize: 8),
                            ),
                            pw.SizedBox(height: 4),

                            bilingualRow(
                              regular,
                              'Inv No',
                              'INV/${receipt.invoiceDate.year}/${receipt.invoiceNumber}',
                              'رقم الفاتورة',
                            ),
                            bilingualRow(
                              regular,
                              'Inv Date',
                              invoiceDateFormatted,
                              'تاريخ الإصدار',
                            ),
                            bilingualRow(
                              regular,
                              'Delivery',
                              deliveryDateFormatted,
                              'تاريخ التوريد',
                            ),
                            bilingualRow(
                              regular,
                              'Inv Type',
                              'Tax Invoice',
                              'نوع الفاتورة',
                            ),
                          ],
                        ),
                      ),

                      // RIGHT COLUMN — ADDRESS + VAT
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            bilingualRow(
                              regular,
                              'Address',
                              receipt.customerAddress ?? '',
                              'العنوان',
                            ),
                            bilingualRow(
                              regular,
                              'VAT No',
                              CompanyFixedData.vatNumber,
                              'الرقم الضريبي',
                            ),
                            bilingualRow(
                              regular,
                              'Due Date',
                              deliveryDateFormatted,
                              'تاريخ الاستحقاق',
                            ),
                            bilingualRow(
                              regular,
                              'Ref',
                              'Office Jed1/0238',
                              'المرجع',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 10),

              // ================= BOX 2 : CUSTOMER DETAILS =================
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FixedColumnWidth(90),
                  1: const pw.FlexColumnWidth(),
                  2: const pw.FixedColumnWidth(90),
                  3: const pw.FlexColumnWidth(),
                },
                children: [
                  // CUSTOMER NAME
                  pw.TableRow(
                    children: [
                      _cell(regular, 'Customer'),
                      _cell(regular, receipt.customerName),
                      _cell(regular, 'اسم العميل'),
                      _cell(regular, receipt.customerName),
                    ],
                  ),

                  // ADDRESS (optional)
                  if (receipt.customerAddress != null &&
                      receipt.customerAddress!.trim().isNotEmpty)
                    pw.TableRow(
                      children: [
                        _cell(regular, 'Address'),
                        _cell(regular, receipt.customerAddress!),
                        _cell(regular, 'العنوان'),
                        _cell(regular, receipt.customerAddress!),
                      ],
                    ),

                  // PHONE NUMBER (optional)
                  if (receipt.customerPhone != null &&
                      receipt.customerPhone!.trim().isNotEmpty)
                    pw.TableRow(
                      children: [
                        _cell(regular, 'Phone No'),
                        _cell(regular, receipt.customerPhone!),
                        _cell(regular, 'الهاتف'),
                        _cell(regular, receipt.customerPhone!),
                      ],
                    ),

                  // CODE (always visible, value empty)
                  pw.TableRow(
                    children: [
                      _cell(regular, 'Code'),
                      _cell(regular, ''),
                      _cell(regular, 'رقم العميل'),
                      _cell(regular, ''),
                    ],
                  ),

                  // CR (always visible, value empty)
                  // pw.TableRow(
                  //   children: [
                  //     _cell(regular, 'CR'),
                  //     _cell(regular, ''),
                  //     _cell(regular, 'السجل التجاري'),
                  //     _cell(regular, ''),
                  //   ],
                  // ),
                  pw.TableRow(
                    children: [
                      _cell(regular, 'CR'),
                      _cell(regular, CompanyFixedData.crNumber),
                      _cell(regular, 'السجل التجاري'),
                      _cell(regular, CompanyFixedData.crNumber),
                    ],
                  ),

                  // VAT NUMBER (hard-coded)
                  pw.TableRow(
                    children: [
                      _cell(regular, 'VAT No'),
                      _cell(regular, CompanyFixedData.vatNumber),
                      _cell(regular, 'الرقم الضريبي'),
                      _cell(regular, CompanyFixedData.vatNumber),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // ================= BOX 4 : ITEMS =================
              // pw.Table(
              //   border: pw.TableBorder.all(),
              //   columnWidths: {
              //     0: const pw.FixedColumnWidth(30),
              //     1: const pw.FlexColumnWidth(4),
              //     2: const pw.FixedColumnWidth(45),
              //     3: const pw.FixedColumnWidth(70),
              //     4: const pw.FixedColumnWidth(45),
              //     5: const pw.FixedColumnWidth(70),
              //   },
              //   children: [
              //     pw.TableRow(
              //       decoration: const pw.BoxDecoration(
              //         color: PdfColors.grey300,
              //       ),
              //       children: [
              //         _cell(bold, 'م\nS'),
              //         _cell(bold, 'البيان\nDescription'),
              //         _cell(bold, 'العدد\nQty'),
              //         _cell(
              //           bold,
              //           'سعر الإيجار والخدمة\nPrice (Rent & Service)',
              //         ),
              //         _cell(bold, 'الضريبة\nVAT'),
              //         _cell(bold, 'الإجمالي\nAmount'),
              //       ],
              //     ),
              //     ...itemRows,
              //     // ...emptyRows,
              //   ],
              // ),

              // ================= BOX 4 : ITEMS =================
              pw.Column(
                children: [
                  // ===== ACTUAL ITEMS TABLE =====
                  pw.Table(
                    border: pw.TableBorder.all(),
                    columnWidths: {
                      0: const pw.FixedColumnWidth(30),
                      1: const pw.FlexColumnWidth(4),
                      2: const pw.FixedColumnWidth(45),
                      3: const pw.FixedColumnWidth(70),
                      4: const pw.FixedColumnWidth(45),
                      5: const pw.FixedColumnWidth(70),
                    },
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.grey300,
                        ),
                        children: [
                          _cell(bold, 'م\nS'),
                          _cell(bold, 'البيان\nDescription'),
                          _cell(bold, 'العدد\nQty'),
                          _cell(
                            bold,
                            'سعر الإيجار والخدمة\nPrice (Rent & Service)',
                          ),
                          _cell(bold, 'الضريبة\nVAT'),
                          _cell(bold, 'الإجمالي\nAmount'),
                        ],
                      ),
                      ...itemRows,
                    ],
                  ),

                  // ===== BLANK SPACE (NO BORDERS) =====
                  if (blankHeight > 0)
                    pw.Container(
                      height: blankHeight,
                      decoration: pw.BoxDecoration(
                        border: pw.Border(
                          left: pw.BorderSide(),
                          right: pw.BorderSide(),
                          bottom: pw.BorderSide(),
                        ),
                      ),
                    ),
                ],
              ),

              pw.SizedBox(height: 10),

              // ================= BOX 5 : QR + TOTAL =================
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FixedColumnWidth(140), // QR column
                  1: const pw.FlexColumnWidth(), // totals column
                },
                children: [
                  pw.TableRow(
                    children: [
                      // ================= QR =================
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Column(
                          children: [
                            pw.BarcodeWidget(
                              barcode: pw.Barcode.qrCode(),
                              data: qrData,
                              width: 110,
                              height: 110,
                            ),
                            pw.SizedBox(height: 6),
                            pw.Text(
                              '1/1',
                              style: pw.TextStyle(font: regular, fontSize: 8),
                            ),
                          ],
                        ),
                      ),

                      // ================= TOTALS =================
                      pw.Table(
                        border: pw.TableBorder.all(),
                        columnWidths: {
                          0: const pw.FlexColumnWidth(3), // English
                          1: const pw.FlexColumnWidth(3), // Arabic
                          2: const pw.FlexColumnWidth(2), // Amount
                        },
                        children: [
                          _totalRow3(
                            regular,
                            'The taxable amount',
                            'المبلغ الخاضع للضريبة',
                            receipt.subTotal,
                          ),
                          _totalRow3(
                            regular,
                            'Discount',
                            'الخصم',
                            receipt.discount ?? 0.0,
                          ),
                          _totalRow3(
                            regular,
                            'Amount after Discount',
                            'الصافي بعد الخصم',
                            receipt.subTotal - (receipt.discount ?? 0.0),
                          ),
                          _totalRow3(
                            regular,
                            'VAT Amount ${receipt.vatPercentage}%',
                            'مبلغ الضريبة %${receipt.vatPercentage}',
                            receipt.vatAmount,
                          ),
                          _totalRow3(
                            bold,
                            'Total Amount with VAT',
                            'إجمالي المبلغ مع الضريبة',
                            receipt.netTotal,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 10),

              // ================= BOX 6: SIGNATURE =================
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(),
                  1: const pw.FlexColumnWidth(),
                  2: const pw.FlexColumnWidth(),
                  3: const pw.FlexColumnWidth(),
                },
                children: [
                  // HEADER ROW
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      _cell(bold, 'Salesman\nالبائع'),
                      _cell(bold, 'Approved by\nاعتمد بواسطة'),
                      _cell(bold, 'Received by\nاستلم بواسطة'),
                      _cell(bold, 'Customer signature\nتوقيع العميل'),
                    ],
                  ),

                  // HARD-CODED VALUES ROW
                  pw.TableRow(
                    children: [
                      _cell(regular, 'Finance'),
                      _cell(regular, 'اعتمد بواسطة'),
                      _cell(regular, 'استلم بواسطة'),
                      _cell(regular, 'توقيع العميل'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/invoice_${receipt.invoiceNumber}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // ================= HELPERS =================

  static pw.Widget _headerBlock(
    pw.Font font,
    String title,
    String body,
    String footer,
    pw.TextAlign align,
  ) {
    return pw.Column(
      crossAxisAlignment: align == pw.TextAlign.left
          ? pw.CrossAxisAlignment.start
          : pw.CrossAxisAlignment.end,
      children: [
        pw.Text(title, style: pw.TextStyle(font: font, fontSize: 9)),
        pw.Text(body, style: pw.TextStyle(font: font, fontSize: 8)),
        pw.SizedBox(height: 3),
        pw.Text(footer, style: pw.TextStyle(font: font, fontSize: 8)),
      ],
    );
  }

  static pw.Widget _boxedInfo(pw.Font font, String title, List<String> lines) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(font: font, fontSize: 9)),
          pw.SizedBox(height: 4),
          ...lines.map(
            (e) => pw.Text(e, style: pw.TextStyle(font: font, fontSize: 8)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _cell(pw.Font font, String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 8)),
    );
  }

  static pw.TableRow _totalRow(pw.Font font, String label, double value) {
    return pw.TableRow(
      children: [_cell(font, label), _cell(font, value.toStringAsFixed(2))],
    );
  }

  static pw.TableRow _totalRow3(
    pw.Font font,
    String enLabel,
    String arLabel,
    double amount,
  ) {
    return pw.TableRow(
      children: [
        _cell(font, enLabel),
        _cell(font, arLabel),
        _cell(font, '${amount.toStringAsFixed(2)} SR'),
      ],
    );
  }

  static String _zatcaQr({
    required String sellerName,
    required String vatNumber,
    required DateTime invoiceDate,
    required double totalWithVat,
    required double vatAmount,
  }) {
    final bytes = <int>[];

    void add(int tag, String value) {
      final v = value.codeUnits;
      bytes
        ..add(tag)
        ..add(v.length)
        ..addAll(v);
    }

    add(1, sellerName);
    add(2, vatNumber);
    add(3, invoiceDate.toIso8601String());
    add(4, totalWithVat.toStringAsFixed(2));
    add(5, vatAmount.toStringAsFixed(2));

    return base64Encode(bytes);
  }
}

// for arabic and english labels
pw.Widget bilingualRow(
  pw.Font font,
  String enLabel,
  String value,
  String arLabel,
) {
  return pw.Row(
    children: [
      pw.Expanded(
        flex: 2,
        child: pw.Text(
          '$enLabel:',
          style: pw.TextStyle(font: font, fontSize: 8),
        ),
      ),
      pw.Expanded(
        flex: 3,
        child: pw.Text(value, style: pw.TextStyle(font: font, fontSize: 8)),
      ),
      pw.Expanded(
        flex: 2,
        child: pw.Text(
          arLabel,
          textAlign: pw.TextAlign.right,
          style: pw.TextStyle(font: font, fontSize: 8),
        ),
      ),
    ],
  );
}
*/


import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shopx/domain/reciept/receipt_data.dart';
import 'package:shopx/domain/settings/company_settings.dart';

// class CompanyFixedData {
//   static const companyNameEn = 'SAQAF NAQAL TRADING Est.';
//   static const companyNameAr = 'مؤسسة سقاف النقل التجارية';
//   static const businessEn = 'MAKKAH - KSA';
//   static const businessAr = 'مكة المكرمة - المملكة العربية السعودية';
//   static const vatNumber = '310185723200003';
//   static const crNumber = '4031213057';
// }

class PdfReceiptService {
  
static Future<pw.ImageProvider> _loadCompanyLogo(
  CompanySettings settings,
) async {
  // If logo URL exists → download it
  if (settings.logoUrl != null && settings.logoUrl!.isNotEmpty) {
    try {
      final uri = Uri.parse(settings.logoUrl!);
      final response = await HttpClient().getUrl(uri).then((r) => r.close());
      final bytes = await consolidateHttpClientResponseBytes(response);
      return pw.MemoryImage(bytes);
    } catch (_) {
      // If download fails → fallback to asset
    }
  }

  // Fallback: bundled default logo
  return pw.MemoryImage(
    (await rootBundle.load(
      'assets/images/pdf_logo.png',
    ))
        .buffer
        .asUint8List(),
  );
}
// this much is new 


  // static Future<File> generateReceiptPdf(ReceiptData receipt) async {
  static Future<File> generateReceiptPdf({
  required ReceiptData receipt,
  required CompanySettings settings,
}) async {
   

    // 🔴 LEGAL SAFETY GUARD (MANDATORY)
  if (settings.companyNameEn.isEmpty ||
      settings.vatNumber.isEmpty ||
      settings.crNumber.isEmpty) {
    throw Exception(
      "Illegal receipt generation: company settings incomplete",
    );
  }

   
    final pdf = pw.Document();

    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Cairo-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Cairo-Bold.ttf'),
    );

    // final logo = pw.MemoryImage(
    //   (await rootBundle.load('assets/images/pdf_logo.png')).buffer.asUint8List(),
    // );
        
    

        final logo = await _loadCompanyLogo(settings);


    final saleDate = receipt.invoiceDate;
    final invoiceDateFormatted =
        '${saleDate.day.toString().padLeft(2, '0')}/${saleDate.month.toString().padLeft(2, '0')}/${saleDate.year}';
    final deliveryDateFormatted =
        '${saleDate.year}-${saleDate.month.toString().padLeft(2, '0')}-${saleDate.day.toString().padLeft(2, '0')}';

    final qrData = _zatcaQr(
      sellerName: settings.companyNameEn,
      vatNumber: settings.vatNumber,
      invoiceDate: receipt.invoiceDate,
      totalWithVat: receipt.netTotal,
      vatAmount: receipt.vatAmount,
    );

    const double itemRowHeight = 20;
    const int minItemRows = 12;

    final itemRows = receipt.items.asMap().entries.map((e) {
      final i = e.key + 1;
      final item = e.value;
      final total = item.unitPrice * item.quantity;
      final vat = total * (receipt.vatPercentage / 100);

      return pw.TableRow(
        children: [
          _cell(regular, '$i', align: pw.TextAlign.center),
          _cell(
            regular,
            item.nameAr?.isNotEmpty == true
                ? '${item.nameAr} (${item.nameEn})'
                : item.nameEn,
          ),
          _cell(regular, item.quantity.toStringAsFixed(2), align: pw.TextAlign.center),
          _cell(regular, item.unitPrice.toStringAsFixed(2), align: pw.TextAlign.center),
          _cell(regular, vat.toStringAsFixed(2), align: pw.TextAlign.center),
          _cell(regular, total.toStringAsFixed(2), align: pw.TextAlign.center),
        ],
      );
    }).toList();

    final int visibleItemCount = receipt.items.length;
    final int remainingRows = visibleItemCount < minItemRows ? minItemRows - visibleItemCount : 0;
    final double blankHeight = remainingRows * itemRowHeight;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (_) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            children: [
              // ================= HEADER =================
              pw.Directionality(
                textDirection: pw.TextDirection.ltr,
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: 
                      _headerBlock(
                        bold,
                         settings.companyNameEn,
                          settings.companyAddressEn, 
                      'VAT No.: ${settings.vatNumber}\nCR No.: ${settings.crNumber}', pw.TextAlign.left),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                      child: pw.Image(logo, width: 65),
                    ),
                    pw.Expanded(
                      child: _headerBlock(bold, settings.companyNameAr, settings.companyAddressAr, 
                      // 'رقم الضريبية : ${settings.vatNumber}\nرقم السجل التجاري : ${settings.crNumber}'
                      'رقم الضريبة : ${settings.vatNumber}\nرقم السجل التجاري : ${settings.crNumber}'

                      , 
                      pw.TextAlign.right),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text('Tax Invoice فاتورة ضريبية', style: pw.TextStyle(font: bold, fontSize: 12)),
              pw.SizedBox(height: 5),

              // ================= VENDOR & INVOICE BOX =================
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                columnWidths: {
                  0: const pw.FixedColumnWidth(80),
                  1: const pw.FlexColumnWidth(),
                  2: const pw.FixedColumnWidth(80),
                },
                children: [
                  pw.TableRow(children: [
                    _cell(bold, 'Vendor'),
                    _cell(bold, settings.companyNameEn, align: pw.TextAlign.center),
                    _cell(bold, 'اسم المورد', align: pw.TextAlign.right),
                  ]),
                ],
              ),
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                columnWidths: {
                  0: const pw.FixedColumnWidth(65),
                  1: const pw.FlexColumnWidth(),
                  2: const pw.FixedColumnWidth(85),
                  3: const pw.FixedColumnWidth(85),
                  4: const pw.FlexColumnWidth(),
                  5: const pw.FixedColumnWidth(85),
                },
                children: [
                  _infoRow(regular, 'Inv No.', 'INV/${receipt.invoiceDate.year}/${receipt.invoiceNumber}', 'رقم الفاتورة', 'Address', receipt.customerAddress ?? '', 'عنوان المورد'),
                  _infoRow(regular, 'Inv. Date', invoiceDateFormatted, 'تاريخ الإصدار', 'VAT. No', settings.vatNumber, 'رقم الضريبة'),
                  _infoRow(regular, 'Delivery', deliveryDateFormatted, 'تاريخ التوريد', 'Due Date', deliveryDateFormatted, 'تاريخ الاستحقاق'),
                  _infoRow(regular, 'Inv. Type', 'Tax Invoice', 'نوع الفاتورة', 'Ref', 'Office Jed1/0238', 'المرجع'),
                ],
              ),

              pw.SizedBox(height: 1),

              // ================= CUSTOMER BOX =================
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                columnWidths: {
                  0: const pw.FixedColumnWidth(65),
                  1: const pw.FlexColumnWidth(),
                  2: const pw.FixedColumnWidth(85),
                  3: const pw.FixedColumnWidth(85),
                  4: const pw.FlexColumnWidth(),
                  5: const pw.FixedColumnWidth(85),
                },
                children: [
                  _infoRow(regular, 'Customer', receipt.customerName, 'اسم العميل', 'Customer', receipt.customerName, 'اسم العميل'),
                  _infoRow(regular, 'Address', receipt.customerAddress ?? '', 'عنوان العميل', 'Address', receipt.customerAddress ?? '', 'عنوان العميل'),
                  _infoRow(regular, 'PhoneNo.', receipt.customerPhone ?? '', 'الهاتف', 'CR', settings.crNumber, 'رقم السجل التجاري'),
                  _infoRow(regular, 'Code', 'Sameer', 'رقم العميل', 'VAT. No', settings.vatNumber, 'رقم الضريبة'),
                ],
              ),

              pw.SizedBox(height: 10),

              // ================= ITEMS TABLE =================
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                columnWidths: {
                  0: const pw.FixedColumnWidth(25),
                  1: const pw.FlexColumnWidth(),
                  2: const pw.FixedColumnWidth(40),
                  3: const pw.FixedColumnWidth(80),
                  4: const pw.FixedColumnWidth(40),
                  5: const pw.FixedColumnWidth(60),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _cell(bold, 'م\nS.', align: pw.TextAlign.center),
                      _cell(bold, 'البيان\nDescription', align: pw.TextAlign.center),
                      _cell(bold, 'العدد\nQty', align: pw.TextAlign.center),
                      _cell(bold, 'سعر الإيجار والخدمة\nPrice(Rent & Service*)', align: pw.TextAlign.center),
                      _cell(bold, 'الضريبة\nVAT', align: pw.TextAlign.center),
                      _cell(bold, 'الإجمالي\nAmount', align: pw.TextAlign.center),
                    ],
                  ),
                  ...itemRows,
                ],
              ),
              if (blankHeight > 0)
                pw.Container(
                  height: blankHeight,
                  decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
                ),

              pw.SizedBox(height: 10),

              // ================= TOTALS & QR =================
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                columnWidths: {0: const pw.FixedColumnWidth(150), 1: const pw.FlexColumnWidth()},
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Column(
                          children: [
                            pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: qrData, width: 85, height: 85),
                            pw.SizedBox(height: 4),
                            pw.Text('صفحة 1/1', style: pw.TextStyle(font: regular, fontSize: 8)),
                          ],
                        ),
                      ),
                      pw.Table(
                        border: pw.TableBorder.all(width: 0.5),
                        children: [
                          _totalRow(regular, 'The taxable amount', 'المبلغ الخاضع للضريبة', receipt.subTotal),
                          _totalRow(regular, 'Discount', 'الخصم', receipt.discount ?? 0.0),
                          _totalRow(regular, 'Amount after Discount', 'الصافي بعد الخصم', receipt.subTotal - (receipt.discount ?? 0.0)),
                          _totalRow(regular, 'VAT Amount ${receipt.vatPercentage}%', 'مبلغ الضريبة ${receipt.vatPercentage}%', receipt.vatAmount),
                          _totalRow(bold, 'Total Amount with VAT', 'اجمالي المبلغ مع الضريبة', receipt.netTotal, isBold: true),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 10),

              // ================= SIGNATURES =================
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _cell(bold, 'Salesman\nالبائع', align: pw.TextAlign.center),
                      _cell(bold, 'Approved by:\nاعتمد بواسطة', align: pw.TextAlign.center),
                      _cell(bold, 'Received by:\nاستلم بواسطة', align: pw.TextAlign.center),
                      _cell(bold, 'Customer signature\nتوقيع العميل', align: pw.TextAlign.center),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _cell(regular, 'Finance', align: pw.TextAlign.center),
                      _cell(regular, '', height: 25),
                      _cell(regular, ''),
                      _cell(regular, ''),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/invoice_${receipt.invoiceNumber}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.TableRow _infoRow(pw.Font font, String enL, String val, String arL, String enL2, String val2, String arL2) {
    return pw.TableRow(children: [
      _cell(font, enL, fontSize: 7),
      _cell(font, val, fontSize: 7, align: pw.TextAlign.center),
      _cell(font, arL, fontSize: 7, align: pw.TextAlign.right),
      _cell(font, enL2, fontSize: 7),
      _cell(font, val2, fontSize: 7, align: pw.TextAlign.center),
      _cell(font, arL2, fontSize: 7, align: pw.TextAlign.right),
    ]);
  }

  static pw.TableRow _totalRow(pw.Font font, String en, String ar, double val, {bool isBold = false}) {
    return pw.TableRow(children: [
      _cell(font, en, fontSize: 8),
      _cell(font, ar, fontSize: 8, align: pw.TextAlign.right),
      _cell(font, '${val.toStringAsFixed(2)} SR', fontSize: 8, align: pw.TextAlign.right),
    ]);
  }

  static pw.Widget _cell(pw.Font font, String text, {pw.TextAlign align = pw.TextAlign.left, double fontSize = 8, double? height}) {
    return pw.Container(
      height: height,
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: fontSize), textAlign: align),
    );
  }

  static pw.Widget _headerBlock(pw.Font font, String title, String body, String footer, pw.TextAlign align) {
    return pw.Column(
      crossAxisAlignment: align == pw.TextAlign.left ? pw.CrossAxisAlignment.start : pw.CrossAxisAlignment.end,
      children: [
        pw.Text(title, style: pw.TextStyle(font: font, fontSize: 10)),
        pw.Text(body, style: pw.TextStyle(font: font, fontSize: 8)),
        pw.Text(footer, style: pw.TextStyle(font: font, fontSize: 8), textAlign: align),
      ],
    );
  }

  static String _zatcaQr({required String sellerName, required String vatNumber, required DateTime invoiceDate, required double totalWithVat, required double vatAmount}) {
    final bytes = <int>[];
    void add(int tag, String value) {
      final v = utf8.encode(value);
      bytes..add(tag)..add(v.length)..addAll(v);
    }
    add(1, sellerName);
    add(2, vatNumber);
    add(3, invoiceDate.toIso8601String());
    add(4, totalWithVat.toStringAsFixed(2));
    add(5, vatAmount.toStringAsFixed(2));
    return base64Encode(bytes);
  }
}


