


import 'sale_item.dart';
import 'payment.dart';

class Sale {
  final int id;
  final int customerId;
  final String salespersonName;
  final String customerName;
  final String customerPhone;

  final List<SaleItem> items;
  final List<Payment> payments;

  final double totalAmount;
  final String paymentStatus;
  final DateTime saleDate;

  Sale({
    required this.id,
    required this.customerId,
    required this.salespersonName,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.payments,
    required this.totalAmount,
    required this.paymentStatus,
    required this.saleDate,
  });

  // factory Sale.fromJson(Map<String, dynamic> json) {
  //   print("🔥 PARSING Sale.fromJson...");

  //   final saleData = json["sale"];

  //   return Sale(
  //     id: saleData["id"],
  //     customerId: saleData["customer_id"],
  //     salespersonName: saleData["salesperson_name"] ?? "",
  //     customerName: saleData["customer_name"] ?? "",
  //     customerPhone: saleData["customer_phone"] ?? "",

  //     items: (json["items"] as List)
  //         .map((i) => SaleItem.fromJson(i))
  //         .toList(),

  //     payments: (json["payments"] as List)
  //         .map((p) => Payment.fromJson(p))
  //         .toList(),

  //     totalAmount: double.parse(saleData["total_amount"].toString()),
  //     paymentStatus: saleData["payment_status"],
  //     saleDate: DateTime.parse(saleData["sale_date"]),
  //   );
  // }

  factory Sale.fromJson(Map<String, dynamic> json) {
  final saleData = json["sale"] ?? json;

  return Sale(
    id: saleData["id"] ?? 0,
    customerId: saleData["customer_id"] ?? 0,

    salespersonName: saleData["salesperson_name"] ?? "",
    customerName: saleData["customer_name"] ?? "",
    customerPhone: saleData["customer_phone"] ?? "",

    items: (json["items"] as List?)?.map((i) => SaleItem.fromJson(i)).toList() ?? [],
    payments: (json["payments"] as List?)?.map((p) => Payment.fromJson(p)).toList() ?? [],

    totalAmount: double.tryParse(saleData["total_amount"].toString()) ?? 0,
    paymentStatus: saleData["payment_status"] ?? "paid",
    saleDate: DateTime.tryParse(saleData["sale_date"]) ?? DateTime.now(),
  );
}

}
