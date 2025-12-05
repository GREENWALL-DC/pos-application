import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ManualEntryPage extends HookConsumerWidget {
  const ManualEntryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final priceController = useTextEditingController();
    final qtyController = useTextEditingController();
    final unitController = useTextEditingController();
return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
  child: Column(
    children: [
      // 🔽 Scrollable content
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              _inputField("Product Name", nameController),
              _inputField("Product Price", priceController,
                  keyboard: TextInputType.number),

              Row(
                children: [
                  Expanded(
                    child: _inputField("Qty", qtyController,
                        keyboard: TextInputType.number),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _inputField("Unit", unitController),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      const SizedBox(height: 15),

      // 🔽 Fixed button at bottom
      SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Add to cart",
            style: TextStyle(fontSize: 16,
            color: Colors.white,
             fontWeight: FontWeight.bold),
          ),
        ),
      ),

      const SizedBox(height: 20), // space above bottom nav
    ],
  ),
);

  }

  Widget _inputField(String title, TextEditingController controller,
      {TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboard,
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
