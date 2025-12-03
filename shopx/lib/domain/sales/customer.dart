class Customer {
  final int id;
  final String name;
  final String phone;
  final String? address;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json["id"],
      name: json["name"],
      phone: json["phone"],
      address: json["address"],
    );
  }
}
