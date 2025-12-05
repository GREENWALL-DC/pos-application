import 'package:flutter/material.dart';
import 'package:shopx/presentation/products/add_product_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      // Add Product button
         floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 👉 When admin taps this, go to AddProductScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddProductScreen(),
            ),
          );
        },
        child: const Icon(Icons.add), // + icon
      ),
      body: const Center(
        child: Text("Welcome Admin"),
      ),
    );
  }
}
