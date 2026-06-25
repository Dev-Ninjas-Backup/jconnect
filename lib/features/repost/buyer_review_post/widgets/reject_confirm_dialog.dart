import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';

class RejectConfirmDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const RejectConfirmDialog({
    required this.onConfirm,
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
                color: Color(0XFFBD001F),
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              'Reject Submission?',
              style: getTextStyle(
                fontsize: 18,
                fontweight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Are you sure you want to reject this proof? This action cannot be undone and will update the order status.',
              textAlign: TextAlign.center,
              style: getTextStyle(
                fontsize: 13,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Get.back(),
                    child: Text(
                      'Cancel',
                      style: getTextStyle(
                        fontsize: 14,
                        fontweight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0XFFBD001F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Get.back(); // Close dialog
                      onConfirm();
                    },
                    child: Text(
                      'Reject',
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
          ],
        ),
      ),
    );
  }
}
