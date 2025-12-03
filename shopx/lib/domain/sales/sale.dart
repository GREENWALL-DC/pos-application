import 'sale_item.dart';
import 'payment.dart';
import 'customer.dart';

class Sale {
  final int id;
  final Customer customer;
  final List<SaleItem> items;
  final List<Payment> payments;
  final double totalAmount;
  final String paymentStatus;
  final DateTime saleDate;

  Sale({
    required this.id,
    required this.customer,
    required this.items,
    required this.payments,
    required this.totalAmount,
    required this.paymentStatus,
    required this.saleDate,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json["sale"]["id"],
      customer: Customer.fromJson(json["sale"]["customer"]),
      items: (json["items"] as List)
          .map((i) => SaleItem.fromJson(i))
          .toList(),
      payments: (json["payments"] as List)
          .map((p) => Payment.fromJson(p))
          .toList(),
      totalAmount: (json["sale"]["total_amount"] as num).toDouble(),
      paymentStatus: json["sale"]["payment_status"],
      saleDate: DateTime.parse(json["sale"]["sale_date"]),
    );
  }
}
