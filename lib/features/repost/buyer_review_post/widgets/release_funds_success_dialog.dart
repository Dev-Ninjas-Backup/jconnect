import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';

class ReleaseFundsSuccessDialog extends StatelessWidget {
  final double amount;
  final String sellerName;

  const ReleaseFundsSuccessDialog({
    required this.amount,
    required this.sellerName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF161616),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF22C55E),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              'Funds Released',
              style: getTextStyle(
                fontsize: 18,
                fontweight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your funds of \$${amount.toStringAsFixed(2)} have been successfully released to $sellerName.',
              textAlign: TextAlign.center,
              style: getTextStyle(
                fontsize: 13,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0XFFBD001F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // Close dialog
                  Get.back();
                  // Close review screen
                  Get.back();
                },
                child: Text(
                  'Close',
                  style: getTextStyle(
                    fontsize: 14,
                    fontweight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
