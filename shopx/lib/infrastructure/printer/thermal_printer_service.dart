//How to talk to a Bluetooth thermal printer
// How to format text for 58mm paper 

// lib/infrastructure/printer/thermal_printer_service.dart

import 'dart:typed_data';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shopx/domain/reciept/receipt_data.dart';


/// Service responsible for printing a 58mm thermal receipt via Bluetooth
class ThermalPrinterService {
  /// Public method used by UI
  static Future<void> printReceipt({
    required ReceiptData receipt,
    required BuildContext context,
  }) async {
    try {
      // 1️⃣ Generate ESC/POS bytes
      final bytes = await _generateReceiptBytes(receipt);

      // 2️⃣ Check printer connection
      final bool isConnected = await PrintBluetoothThermal.connectionStatus;

      if (!isConnected) {
        // Printer not connected → graceful message
        _showMessage(context, "Receipt generated. Printer not connected.");
        return;
      }

      // 3️⃣ Send bytes to printer
      await PrintBluetoothThermal.writeBytes(bytes);

      _showMessage(context, "Receipt printed successfully");
    } catch (e) {
      _showMessage(context, "Printing failed: $e");
    }
  }

  /// Builds ESC/POS instructions for a 58mm receipt
  static Future<List<int>> _generateReceiptBytes(ReceiptData r) async {
    final profile = await CapabilityProfile.load();
    final gen = Generator(PaperSize.mm58, profile);

    List<int> bytes = [];

    // --------------------
    // HEADER (CENTERED)
    // --------------------
    bytes += gen.text(
      r.companyNameEn,
      styles: PosStyles(bold: true, align: PosAlign.center),
    );

    bytes += gen.text(
      r.companyNameAr,
      styles: PosStyles(align: PosAlign.center),
    );

    bytes += gen.text(
      "${r.city}, ${r.country}",
      styles: PosStyles(align: PosAlign.center),
    );

    bytes += gen.text(
      "CR: ${r.crNumber}",
      styles: PosStyles(align: PosAlign.center),
    );

    bytes += gen.text(
      "VAT: ${r.vatNumber}",
      styles: PosStyles(align: PosAlign.center),
    );

    bytes += gen.text(
      "Mobile: ${r.mobile}",
      styles: PosStyles(align: PosAlign.center),
    );

    bytes += gen.hr();

    // --------------------
    // INVOICE INFO
    // --------------------
    bytes += gen.text("Customer : ${r.customerName}");
    bytes += gen.text("Invoice  : ${r.invoiceNumber}");
    bytes += gen.text("Date     : ${_formatDate(r.invoiceDate)}");

    bytes += gen.hr();

    // --------------------
    // ITEMS HEADER
    // --------------------
    bytes += gen.row([
      PosColumn(text: 'Item', width: 6),
      PosColumn(text: 'Qty', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(text: 'Total', width: 4, styles: PosStyles(align: PosAlign.right)),
    ]);

    // --------------------
    // ITEMS LIST
    // --------------------
    for (final item in r.items) {
      bytes += gen.row([
        PosColumn(text: item.nameEn, width: 6),
        PosColumn(text: item.quantity.toString(), width: 2, styles: PosStyles(align: PosAlign.right)),
        PosColumn(text: item.total.toStringAsFixed(2), width: 4, styles: PosStyles(align: PosAlign.right)),
      ]);
    }

    bytes += gen.hr();

    // --------------------
    // TOTALS
    // --------------------
    bytes += gen.row([
      PosColumn(text: 'Sub Total', width: 8),
      PosColumn(text: r.subTotal.toStringAsFixed(2), width: 4, styles: PosStyles(align: PosAlign.right)),
    ]);

    bytes += gen.row([
      PosColumn(text: 'VAT ${r.vatPercentage.toStringAsFixed(0)}%', width: 8),
      PosColumn(text: r.vatAmount.toStringAsFixed(2), width: 4, styles: PosStyles(align: PosAlign.right)),
    ]);

    bytes += gen.row([
      PosColumn(
        text: 'NET TOTAL',
        width: 8,
        styles: PosStyles(bold: true),
      ),
      PosColumn(
        text: r.netTotal.toStringAsFixed(2),
        width: 4,
        styles: PosStyles(bold: true, align: PosAlign.right),
      ),
    ]);

    bytes += gen.hr();

    // --------------------
    // QR CODE (ZATCA)
    // --------------------
    bytes += gen.qrcode(r.qrPayload, size: QRSize.size4);

    bytes += gen.text(
      "Thank You",
      styles: PosStyles(align: PosAlign.center, bold: true),
    );

    bytes += gen.text(
      "شكراً لكم",
      styles: PosStyles(align: PosAlign.center),
    );

    bytes += gen.cut();

    return bytes;
  }

  static String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year} "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
