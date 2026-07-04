import 'package:flutter/material.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/repost/repost_listings/controller/repost_listing_controller.dart';
import 'package:jconnect/features/repost/repost_listings/model/repost_listing_model.dart';

class RepostListingCard extends StatelessWidget {
  const RepostListingCard({
    super.key,
    required this.item,
    required this.isActive,
    required this.controller,
  });

  final RepostListingModel item;
  final bool isActive;
  final RepostListingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2C2C2C),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Image.asset(
            item.platformIcon,
          width: 40,
          height: 40,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            'assets/icons/social-media.png',
            width: 40,
            height: 40,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.platformDisplayName,
                style: getTextStyle(
                  color: Colors.white,
                  fontsize: 16,
                  fontweight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${item.price.toStringAsFixed(2)}',
                style: getTextStyle(
                  color: Colors.white,
                  fontsize: 15,
                  fontweight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isActive ? 'Active' : 'Inactive',
              style: getTextStyle(
                color: isActive ? Colors.green : Colors.grey,
                fontsize: 13,
                fontweight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => controller.toggleStatus(item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 26,
                padding: const EdgeInsets.all(3),
                alignment: isActive ? Alignment.centerRight : Alignment.centerLeft,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  color: isActive
                      ? Colors.green.withValues(alpha: 0.15)
                      : const Color(0xFF1E1E1E),
                  border: Border.all(
                    color: isActive
                        ? Colors.green.withValues(alpha: 0.8)
                        : const Color(0xFF3A3A3A),
                    width: 1.5,
                  ),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? Colors.green : Colors.grey,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            )
                          ]
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
                );
  }
}
