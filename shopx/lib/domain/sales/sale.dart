// import 'sale_item.dart';
// import 'payment.dart';

// class Sale {
//   final int id;
//   final int customerId;

//   final List<SaleItem> items;
//   final List<Payment> payments;
//   final double totalAmount;
//   final String paymentStatus;
//   final DateTime saleDate;

//   Sale({
//     required this.id,
//     required this.customerId,
//     required this.items,
//     required this.payments,
//     required this.totalAmount,
//     required this.paymentStatus,
//     required this.saleDate,
//   });

//   factory Sale.fromJson(Map<String, dynamic> json) {
//     return Sale(
//       id: json["sale"]["id"],
//        customerId: json["sale"]["customer_id"],
//       items: (json["items"] as List)
//           .map((i) => SaleItem.fromJson(i))
//           .toList(),
//       payments: (json["payments"] as List)
//           .map((p) => Payment.fromJson(p))
//           .toList(),
//       totalAmount: (json["sale"]["total_amount"] as num).toDouble(),
//       paymentStatus: json["sale"]["payment_status"],
//       saleDate: DateTime.parse(json["sale"]["sale_date"]),
//     );
//   }
// }


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

  factory Sale.fromJson(Map<String, dynamic> json) {
    print("🔥 PARSING Sale.fromJson...");

    final saleData = json["sale"];

    return Sale(
      id: saleData["id"],
      customerId: saleData["customer_id"],
      salespersonName: saleData["salesperson_name"] ?? "",
      customerName: saleData["customer_name"] ?? "",
      customerPhone: saleData["customer_phone"] ?? "",

      items: (json["items"] as List)
          .map((i) => SaleItem.fromJson(i))
          .toList(),

      payments: (json["payments"] as List)
          .map((p) => Payment.fromJson(p))
          .toList(),

      totalAmount: double.parse(saleData["total_amount"].toString()),
      paymentStatus: saleData["payment_status"],
      saleDate: DateTime.parse(saleData["sale_date"]),
    );
  }
}
