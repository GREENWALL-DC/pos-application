import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart'; // ✅ REQUIRED
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shopx/application/payments/payments_notifier.dart';
import 'package:shopx/application/sales/sales_notifier.dart';
import 'package:shopx/domain/sales/sale.dart';

class TransactionDetailSheet extends HookConsumerWidget {
  final Sale sale;
  final ScrollController scrollController;

  const TransactionDetailSheet({
    super.key,
    required this.sale,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ FETCH FULL INVOICE WHEN SHEET OPENS
   useEffect(() {
      Future.microtask(() {
        ref.read(salesNotifierProvider.notifier).fetchSaleById(sale.id);
      });
      return null;
    }, []);


    final salesState = ref.watch(salesNotifierProvider);
    final invoice = salesState.sale; // FULL invoice
    final items = invoice?.items ?? [];

    final isPending = sale.paymentStatus == "pending";

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        controller: scrollController,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          const Text(
            "Transaction Details",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          _row("Invoice ID", sale.id.toString()),
          _row("Customer", sale.customerName ?? "-"),
          _row("Date", DateFormat.yMMMd().add_jm().format(sale.saleDate)),
          _row("Total Amount", "SAR ${sale.totalAmount.toStringAsFixed(2)}"),
          _row("Payment Status", sale.paymentStatus.toUpperCase()),

          const SizedBox(height: 24),

          const Text("Items", style: TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(height: 8),

          // ...sale.items.map(
          //   (item) => Padding(
          //     padding: const EdgeInsets.only(bottom: 6),
          //     child: Text(
          //       "${item.productName} × ${item.quantity}",
          //       style: const TextStyle(fontSize: 14),
          //     ),
          //   ),
          // ),

          // ✅ ITEMS LIST
          if (items.isEmpty)
            const Text(
              "No items available",
              style: TextStyle(color: Colors.grey),
            )
          else















            // ================= ITEMS LIST =================
...items.map((item) {
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
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            Text(
              "SAR ${item.totalPrice.toStringAsFixed(2)}",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}),

          const SizedBox(height: 30),

          // ✅ Only show button if pending
          if (isPending)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () async {
                await ref
                    .read(paymentsNotifierProvider.notifier)
                    .markPaymentAsPaid(sale.id);

                Navigator.pop(context);

                // ✅ DO NOTHING HERE
                // Parent screen will refresh correctly
              },

              child: const Text(
                "Mark as Paid",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
