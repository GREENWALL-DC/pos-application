class Product {
   final String? id;        // id comes only when product is fetched from backend
  final String name;       // product name
  final double price;      // product price
  final String category;   // product category (Tea, Coffee, etc.)
  final String description;// product description
  final String unit;  

    final List<String> images;   // <-- ADD THIS


  const Product({
    this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.description,
     required this.unit, 
      this.images = const [],     // <-- default empty
  });

 
  // Convert JSON → Product (used when fetching products from backend)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["id"]?.toString(),
      name: json["name"] ?? "",
      price: double.tryParse(json["price"].toString()) ?? 0.0,
      category: json["category"] ?? "",
      description: json["description"] ?? "",
        unit: json["unit"] ?? "",
         images: json["images"] != null
          ? List<String>.from(json["images"])
          : [],
    );
  }

 // Convert Product → JSON (send to backend)
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "price": price,
      "category": category,
      "description": description,
       "unit": unit,
    };
  }
}