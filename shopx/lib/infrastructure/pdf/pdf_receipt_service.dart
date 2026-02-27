import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shopx/domain/reciept/receipt_data.dart';
import 'package:shopx/domain/settings/company_settings.dart';

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
      )).buffer.asUint8List(),
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

    // ✅ NEW: Arabic font (clean & readable)
    final arabicRegular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf'),
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
          _cell(
            regular,
            item.quantity.toStringAsFixed(2),
            align: pw.TextAlign.center,
          ),
          _cell(
            regular,
            item.unitPrice.toStringAsFixed(2),
            align: pw.TextAlign.center,
          ),
          _cell(regular, vat.toStringAsFixed(2), align: pw.TextAlign.center),
          _cell(regular, total.toStringAsFixed(2), align: pw.TextAlign.center),
        ],
      );
    }).toList();

    final int visibleItemCount = receipt.items.length;
    final int remainingRows = visibleItemCount < minItemRows
        ? minItemRows - visibleItemCount
        : 0;
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
              // pw.Directionality(
              //   textDirection: pw.TextDirection.ltr,
              //   child: pw.Row(
              //     children: [
              //       pw.Expanded(
              //         child: _headerBlock(
              //           bold,
              //           settings.companyNameEn,
              //           settings.companyAddressEn,
              //           'VAT No.: ${settings.vatNumber}\nCR No.: ${settings.crNumber}',
              //           pw.TextAlign.left,
              //         ),
              //       ),
              //       pw.Padding(
              //         padding: const pw.EdgeInsets.symmetric(horizontal: 10),
              //         child: pw.Image(logo, width: 65),
              //       ),
              //       pw.Expanded(
              //         child: _headerBlockArabic(
              //           bold,
              //           settings.companyNameAr,
              //           settings.companyAddressAr,
              //           'رقم الضريبة : ${_toArabicDigits(settings.vatNumber)}\n'
              //           'رقم السجل التجاري : ${_toArabicDigits(settings.crNumber)}',
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              pw.Directionality(
                textDirection: pw.TextDirection.ltr,
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // ✅ ENGLISH — LEFT
                    pw.Expanded(
                      flex: 4,
                      child: _headerBlock(
                        bold,
                        settings.companyNameEn,
                        settings.companyAddressEn,
                        'VAT No.: ${settings.vatNumber}\nCR No.: ${settings.crNumber}',
                        pw.TextAlign.left,
                      ),
                    ),

                    // ✅ LOGO — CENTER
                    pw.Expanded(
                      flex: 2,
                      child: pw.Center(child: pw.Image(logo, width: 65)),
                    ),

                    // ✅ ARABIC — RIGHT (FLUSHED)
                   pw.Expanded(
  flex: 4,
  child: pw.Align(
    alignment: pw.Alignment.topRight, // 🔥 THIS IS THE FIX
    child: _headerBlockArabic(
      arabicRegular,
      settings.companyNameAr,
      settings.companyAddressAr,
      'رقم الضريبة : ${_toArabicDigits(settings.vatNumber)}\n'
      'رقم السجل التجاري : ${_toArabicDigits(settings.crNumber)}',
    ),
  ),
),

                  ],
                ),
              ),

              pw.SizedBox(height: 5),
              pw.Text(
                'Tax Invoice فاتورة ضريبية',
                style: pw.TextStyle(font: bold, fontSize: 12),
              ),
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
                  pw.TableRow(
                    children: [
                      _cell(bold, 'Vendor'),
                      _cell(
                        bold,
                        settings.companyNameEn,
                        align: pw.TextAlign.center,
                      ),
                      _cell(
                        arabicRegular,
                        'اسم المورد',
                        align: pw.TextAlign.right,
                      ),
                    ],
                  ),
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
                  _infoRow(
                    regular,
                    arabicRegular,
                    'Inv No.',
                    'INV/${receipt.invoiceDate.year}/${receipt.invoiceNumber}',
                    'رقم الفاتورة',
                    'Address',
                    // receipt.customerAddress ?? '',
                  settings.companyAddressEn,
                    'عنوان المورد',
                  ),
                  _infoRow(
                    regular,
                    arabicRegular,
                    'Inv. Date',
                    invoiceDateFormatted,
                    'تاريخ الإصدار',
                    'VAT. No',
                    settings.vatNumber,
                    'رقم الضريبة',
                  ),

                  // _infoRow(
                  //   regular,
                  //   arabicRegular,
                  //   'Delivery',
                  //   // deliveryDateFormatted,
                  //   '',
                  //   'تاريخ التوريد',
                  //   'Due Date',
                  //   // deliveryDateFormatted,
                  //   '',
                  //   'تاريخ الاستحقاق',
                  // ),
                  // _infoRow(
                  //   regular,
                  //   arabicRegular,
                  //   'Inv. Type',
                  //   'Tax Invoice',
                  //   'نوع الفاتورة',
                  //   'Ref',
                  //   // 'Office Jed1/0238',
                  //   '',
                  //   'المرجع',
                  // ),
                ],
              ),

              pw.SizedBox(height: 10),

              // pw.Table(
              //   border: pw.TableBorder.all(width: 0.5),
              //   columnWidths: {
              //     0: const pw.FixedColumnWidth(65), // English label
              //     1: const pw.FlexColumnWidth(), // Combined value
              //     2: const pw.FixedColumnWidth(85), // Arabic label
              //   },
              //   children: [
              //     // ---------- CUSTOMER ----------
              //     pw.TableRow(
              //       children: [
              //         _cell(regular, 'Customer'),
              //         _cell(
              //           regular,
              //           receipt.customerName,
              //           align: pw.TextAlign.center,
              //         ),
              //         _cell(
              //           arabicRegular,
              //           'اسم العميل',
              //           align: pw.TextAlign.right,
              //         ),
              //       ],
              //     ),

              //     // ---------- ADDRESS ----------
              //     pw.TableRow(
              //       children: [
              //         _cell(regular, 'Address'),
              //         _cell(
              //           regular,
              //           receipt.customerAddress ?? '',
              //           align: pw.TextAlign.center,
              //         ),
              //         _cell(
              //           arabicRegular,
              //           'عنوان العميل',
              //           align: pw.TextAlign.right,
              //         ),
              //       ],
              //     ),

              //     _infoRow(
              //       regular,
              //       arabicRegular,
              //       'PhoneNo.',
              //       receipt.customerPhone ?? '',
              //       'الهاتف',
              //       'CR',
              //       settings.crNumber,
              //       'رقم السجل التجاري',
              //     ),
              //     _infoRow(
              //       regular,
              //       arabicRegular,
              //       'Code',
              //       // 'Sameer',
              //       '',
              //       'رقم العميل',
              //       'VAT. No',
              //       settings.vatNumber,
              //       'رقم الضريبة',
              //     ),
              //   ],
              // ),

              pw.Table(
  border: pw.TableBorder.all(width: 0.5),
  columnWidths: {
    0: const pw.FixedColumnWidth(65), // Consistent width for English labels
    1: const pw.FlexColumnWidth(),    // Dynamic middle area
    2: const pw.FixedColumnWidth(85), // Consistent width for Arabic labels
  },
  children: [
    // ---------- CUSTOMER ----------
    pw.TableRow(
      children: [
        _cell(regular, 'Customer'),
        _cell(
          regular,
          receipt.customerName,
          align: pw.TextAlign.center,
        ),
        _cell(
          arabicRegular,
          'اسم العميل',
          align: pw.TextAlign.right,
        ),
      ],
    ),

    // ---------- ADDRESS ----------
    pw.TableRow(
      children: [
        _cell(regular, 'Address'),
        _cell(
          regular,
          receipt.customerAddress ?? '',
          align: pw.TextAlign.center,
        ),
        _cell(
          arabicRegular,
          'عنوان العميل',
          align: pw.TextAlign.right,
        ),
      ],
    ),

    // ---------- PHONE & CR ----------
    _infoRow(
      regular,
      arabicRegular,
      'PhoneNo.',
      receipt.customerPhone ?? '',
      'الهاتف',
      'CR',
      settings.crNumber,
      'السجل التجاري', // Matches your image descriptor
    ),

    // ---------- CODE & VAT ----------
    _infoRow(
      regular,
      arabicRegular,
      'Code',
     '', // 'Sameer (Makkah)', // You can pass your dynamic data here
      'رقم العميل',
      'VAT. No',
      // settings.vatNumber,
       receipt.customerVat ?? '', 
      'الرقم الضريبي',
    ),
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
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    children: [
                      _cell(arabicRegular, 'م\nS.', align: pw.TextAlign.center),

                      _cell(
                        arabicRegular,
                        'البيان\nDescription',
                        align: pw.TextAlign.center,
                      ),

                      _cell(
                        arabicRegular,
                        'العدد\nQty',
                        align: pw.TextAlign.center,
                      ),
                      _cell(
                        arabicRegular,
                        'سعر الإيجار والخدمة\nPrice(Rent & Service*)',
                        align: pw.TextAlign.center,
                      ),
                      _cell(
                        arabicRegular,
                        'الضريبة\nVAT',
                        align: pw.TextAlign.center,
                      ),
                      _cell(
                        arabicRegular,
                        'الإجمالي\nAmount',
                        align: pw.TextAlign.center,
                      ),
                    ],
                  ),
                  ...itemRows,
                ],
              ),
              if (blankHeight > 0)
                pw.Container(
                  height: blankHeight,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 0.5),
                  ),
                ),

              pw.SizedBox(height: 10),

              // ================= TOTALS & QR =================
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                columnWidths: {
                  0: const pw.FixedColumnWidth(150),
                  1: const pw.FlexColumnWidth(),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Column(
                          children: [
                            pw.BarcodeWidget(
                              barcode: pw.Barcode.qrCode(),
                              data: qrData,
                              width: 85,
                              height: 85,
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'صفحة 1/1',
                              style: pw.TextStyle(font: regular, fontSize: 8),
                            ),
                          ],
                        ),
                      ),
                      pw.Table(
                        border: pw.TableBorder.all(width: 0.5),
                        children: [
                          _totalRow(
                            regular,
                            arabicRegular,
                            'The taxable amount',
                            'المبلغ الخاضع للضريبة',
                            receipt.subTotal,
                          ),
                          _totalRow(
                            regular,
                            arabicRegular,
                            'Discount',
                            'الخصم',
                            receipt.discount ?? 0.0,
                          ),
                          _totalRow(
                            regular,
                            arabicRegular,
                            'Amount after Discount',
                            'الصافي بعد الخصم',
                            receipt.subTotal - (receipt.discount ?? 0.0),
                          ),
                          _totalRow(
                            regular,
                            arabicRegular,
                            'VAT Amount ${receipt.vatPercentage}%',
                            'مبلغ الضريبة ${receipt.vatPercentage}%',
                            receipt.vatAmount,
                          ),
                          _totalRow(
                            bold,
                            arabicRegular,
                            'Total Amount with VAT',
                            'اجمالي المبلغ مع الضريبة',
                            receipt.netTotal,
                            isBold: true,
                          ),
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
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    children: [
                      _cell(
                        arabicRegular,
                        'Salesman\nالبائع',
                        align: pw.TextAlign.center,
                      ),
                      _cell(
                        arabicRegular,
                        'Approved by:\nاعتمد بواسطة',
                        align: pw.TextAlign.center,
                      ),
                      _cell(
                        arabicRegular,
                        'Received by:\nاستلم بواسطة',
                        align: pw.TextAlign.center,
                      ),
                      _cell(
                        arabicRegular,
                        'Customer signature\nتوقيع العميل',
                        align: pw.TextAlign.center,
                      ),
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



  // static pw.TableRow _infoRow(
  //   pw.Font enFont,
  //   pw.Font arFont,
  //   String enL,
  //   String val,
  //   String arL,
  //   String enL2,
  //   String val2,
  //   String arL2,
  // ) {
  //   return pw.TableRow(
  //     children: [
  //       _cell(enFont, enL, fontSize: 7),
  //       _cell(enFont, val, fontSize: 7, align: pw.TextAlign.center),
  //       _cell(arFont, arL, fontSize: 7, align: pw.TextAlign.right),
  //       _cell(enFont, enL2, fontSize: 7),
  //       _cell(enFont, val2, fontSize: 7, align: pw.TextAlign.center),
  //       _cell(arFont, arL2, fontSize: 7, align: pw.TextAlign.right),
  //     ],
  //   );
  // }

  static pw.TableRow _infoRow(
    pw.Font enFont,
    pw.Font arFont,
    String enL,
    String val,
    String arL,
    String enL2,
    String val2,
    String arL2,
  ) {
    return pw.TableRow(
      children: [
        // 1. Left Label (e.g., PhoneNo. / Code)
        _cell(enFont, enL, fontSize: 7),
        
        // 2. Middle Section: A nested table to create the split boxes
        pw.Table(
          border: const pw.TableBorder(
            verticalInside: pw.BorderSide(width: 0.5),
          ),
          columnWidths: {
            0: const pw.FlexColumnWidth(),   // Value 1
            1: const pw.FixedColumnWidth(45), // Arabic Label (Middle)
            2: const pw.FixedColumnWidth(45), // English Label (Middle)
            3: const pw.FlexColumnWidth(),   // Value 2
          },
          children: [
            pw.TableRow(
              children: [
                _cell(enFont, val, fontSize: 7, align: pw.TextAlign.center),
                _cell(arFont, arL, fontSize: 7, align: pw.TextAlign.center),
                _cell(enFont, enL2, fontSize: 7, align: pw.TextAlign.center),
                _cell(enFont, val2, fontSize: 7, align: pw.TextAlign.center),
              ],
            ),
          ],
        ),
        
        // 3. Right Label (e.g., Arabic descriptors)
        _cell(arFont, arL2, fontSize: 7, align: pw.TextAlign.right),
      ],
    );
  }


  

  // static pw.TableRow _totalRow(
  //   pw.Font font,
  //   String en,
  //   String ar,
  //   double val, {
  //   bool isBold = false,
  // }) {
  //   return pw.TableRow(
  //     children: [
  //       _cell(font, en, fontSize: 8),
  //       _cell(font, ar, fontSize: 8, align: pw.TextAlign.right),
  //       _cell(
  //         font,
  //         '${val.toStringAsFixed(2)} SR',
  //         fontSize: 8,
  //         align: pw.TextAlign.right,
  //       ),
  //     ],
  //   );
  // }

  static pw.TableRow _totalRow(
    pw.Font enFont,
    pw.Font arFont,
    String en,
    String ar,
    double val, {
    bool isBold = false,
  }) {
    return pw.TableRow(
      children: [
        _cell(enFont, en, fontSize: 8),
        _cell(arFont, ar, fontSize: 8, align: pw.TextAlign.right),
        _cell(
          enFont,
          '${val.toStringAsFixed(2)} SR',
          fontSize: 8,
          align: pw.TextAlign.right,
        ),
      ],
    );
  }

  // static pw.Widget _cell(
  //   pw.Font font,
  //   String text, {
  //   pw.TextAlign align = pw.TextAlign.left,
  //   double fontSize = 8,
  //   double? height,
  // }) {
  //   return pw.Container(
  //     height: height,
  //     padding: const pw.EdgeInsets.all(4),
  //     child: pw.Text(
  //       text,
  //       style: pw.TextStyle(font: font, fontSize: fontSize),
  //       textAlign: align,
  //     ),
  //   );
  // }

  static pw.Widget _cell(
    pw.Font font,
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
    double fontSize = 8,
    double? height,
  }) {
    final bool isArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);

    return pw.Directionality(
      textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      child: pw.Container(
        height: height,
        padding: const pw.EdgeInsets.all(4),
        child: pw.Text(
          text,
          style: pw.TextStyle(font: font, fontSize: fontSize),
          textAlign: isArabic ? pw.TextAlign.right : align,
        ),
      ),
    );
  }

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
        pw.Text(title, style: pw.TextStyle(font: font, fontSize: 10)),
        pw.Text(body, style: pw.TextStyle(font: font, fontSize: 8)),
        pw.Text(
          footer,
          style: pw.TextStyle(font: font, fontSize: 8),
          textAlign: align,
        ),
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
      final v = utf8.encode(value);
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

  //new block
  static pw.Widget _headerBlockArabic(
    pw.Font font,
    String title,
    String body,
    String footer,
  ) {
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text(title, style: pw.TextStyle(font: font, fontSize: 10)),
          pw.Text(body, style: pw.TextStyle(font: font, fontSize: 8)),
          pw.Text(
            footer,
            style: pw.TextStyle(font: font, fontSize: 8),
            textAlign: pw.TextAlign.right,
          ),
        ],
      ),
    );
  }

  //new block
  static String _toArabicDigits(String input) {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    for (int i = 0; i < western.length; i++) {
      input = input.replaceAll(western[i], arabic[i]);
    }
    return input;
  }
}
