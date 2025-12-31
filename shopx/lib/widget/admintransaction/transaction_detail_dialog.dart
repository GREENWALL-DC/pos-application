import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shopx/domain/sales/sale.dart';

class TransactionDetailsDialog extends StatelessWidget {
  final Sale sale;
  final VoidCallback? onMarkAsPaid;

  const TransactionDetailsDialog({
    super.key,
    required this.sale,
    this.onMarkAsPaid,
  });

  bool get _isPending => sale.paymentStatus.toUpperCase() == 'PENDING';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context),
            const SizedBox(height: 20),

            _infoRow("Customer", sale.customerName),
            _infoRow("Phone", sale.customerPhone),
            _infoRow("Salesperson", sale.salespersonName),
            _infoRow(
              "Date",
              DateFormat('dd MMM yyyy, hh:mm a').format(sale.saleDate),
            ),

            const Divider(height: 32),

            _amountRow("Subtotal", sale.subtotalAmount),
            _amountRow("Discount", sale.discountAmount),
            _amountRow(
              "VAT (${sale.vatPercentage.toStringAsFixed(0)}%)",
              sale.vatAmount,
            ),

            const Divider(height: 24),

            _amountRow(
              "Total Amount",
              sale.totalAmount,
              isBold: true,
            ),

            const SizedBox(height: 20),


            // ================= ITEMS =================

const Text(
  "Items",
  style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 12),

if (sale.items.isEmpty)
  const Text(
    "No items available",
    style: TextStyle(color: Colors.grey),
  )
else
  ...sale.items.map((item) {
    final unitPrice = item.totalPrice / item.quantity;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.productName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${item.quantity} × SAR ${unitPrice.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                "SAR ${item.totalPrice.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }),

const SizedBox(height: 24),


            _statusChip(),

            const SizedBox(height: 24),

            if (_isPending) _markAsPaidButton(context),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Transaction Details",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  // ================= INFO ROW =================

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? "-" : value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= AMOUNT ROW =================

  Widget _amountRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF374151),
            ),
          ),
          Text(
            "SAR ${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ================= STATUS CHIP =================

  Widget _statusChip() {
    final status = sale.paymentStatus.toUpperCase();

    Color bgColor;
    switch (status) {
      case 'PAID':
        bgColor = const Color(0xFF1D72D6);
        break;
      case 'PENDING':
        bgColor = const Color(0xFFF59E0B);
        break;
      case 'VOID':
        bgColor = const Color(0xFF9CA3AF);
        break;
      default:
        bgColor = const Color(0xFF1D72D6);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ================= MARK AS PAID =================

  Widget _markAsPaidButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onMarkAsPaid,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: const Color(0xFF1D72D6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Mark as Paid",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
