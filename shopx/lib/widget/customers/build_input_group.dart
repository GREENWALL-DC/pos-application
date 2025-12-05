
  // --- Helper Widget for Inputs ---
  import 'package:flutter/material.dart';

Widget buildInputGroup(
    String label,
    TextEditingController controller,
    VoidCallback onChanged, {
    bool isPhone = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6), // Light grey background
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: controller,
              onChanged: (_) => onChanged(),
              keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
              maxLines: maxLines,
              decoration: InputDecoration(
               
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
