// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';

class ViewOrderDetailsWidget extends StatelessWidget {
  const ViewOrderDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.backGroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      child: Container(
        width: 360,
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// --- Title ---
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Order Details",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 14),

            /// --- Order Info Box ---
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF141414),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white10),
              ),
              padding: EdgeInsets.all(14),
              child: Column(
                children: [
                  infoRow("Order ID", "#DJCX29381"),
                  infoRow("Order Created", "14 Oct 2025"),
                  infoRow("Delivery Date", "18 Oct 2025"),
                  infoRow("Service Price", "\$50.00"),
                  infoRow("Platform Fee (10%)", "\$5"),
                  Divider(color: Colors.white24, height: 18),
                  SizedBox(height: 6),
                  infoRow("Total", "\$55", bold: true),
                  SizedBox(height: 15),

                  /// --- Secure Payment Box ---
                  Container(
                    padding: EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.security, color: Colors.white54, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Payment is held securely until post is confirmed live.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),

                  /// --- Stripe Secure Text ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "stripe",
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                      SizedBox(width: 5),
                      Text(
                        "Secured by Stripe",
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 22),

            /// --- Done Button ---
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.redColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Done",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper for consistent rows
  Widget infoRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
