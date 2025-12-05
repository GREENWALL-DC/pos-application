
  // ================= HELPER: CARD WIDGET =================
  import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shopx/domain/sales/sale.dart';

Widget buildTransactionCard(Sale sale, Color primaryBlue) {
    // Format Time: 10:00 AM
    final timeString = DateFormat('hh:mm a').format(sale.saleDate);
    
    // Fake Transaction ID format based on ID (to match design #TRX...)
    final trxId = "#TRX${sale.id.toString().padLeft(10, '0')}";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
           blurRadius: 20,
color: Colors.black.withOpacity(0.06),

            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Side Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount
                Text(
                  "SAR ${sale.totalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                // Time & TRX ID
                Text(
                  "$timeString - $trxId",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF536471), // Grey
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Right Side Button (PAID)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: primaryBlue,
borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "PAID",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          )
        ],
      ),
    );
  }
