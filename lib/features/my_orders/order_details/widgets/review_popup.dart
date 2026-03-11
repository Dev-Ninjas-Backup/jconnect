import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';

class ReviewPopup extends StatefulWidget {
  final Function(int rating, String reviewText) onSubmit;

  const ReviewPopup({super.key, required this.onSubmit});

  @override
  State<ReviewPopup> createState() => _ReviewPopupState();
}

class _ReviewPopupState extends State<ReviewPopup> {
  int selectedRating = 0;
  final TextEditingController reviewController = TextEditingController();

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white54, width: 1.5),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Star rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedRating = index + 1;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Icon(
                      Icons.star,
                      size: 40,
                      color: index < selectedRating
                          ? Colors.white
                          : Colors.white24,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // "Rate the Artist" text
            Text(
              'Rate the Artist',
              style: getTextStyle(
                color: AppColors.primaryTextColor,
                fontsize: 18,
                fontweight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),

            // "Write a review" label
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Write a review',
                style: getTextStyle(
                  color: AppColors.primaryTextColor,
                  fontsize: 14,
                  fontweight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Review text field
            Container(
              height: 150,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF242629),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: TextField(
                controller: reviewController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: getTextStyle(
                  color: AppColors.primaryTextColor,
                  fontsize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Give a review to the artist',
                  hintStyle: getTextStyle(
                    color: AppColors.secondaryTextColor,
                    fontsize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Done button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedRating == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a rating'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  if (reviewController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please write a review'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  widget.onSubmit(selectedRating, reviewController.text.trim());
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.redColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Done',
                  style: getTextStyle(
                    color: Colors.white,
                    fontsize: 16,
                    fontweight: FontWeight.w600,
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
