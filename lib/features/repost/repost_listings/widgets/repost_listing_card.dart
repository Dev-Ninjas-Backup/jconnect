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
    this.onEdit,
    this.onDelete,
  });

  final RepostListingModel item;
  final bool isActive;
  final RepostListingController controller;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C2C2C), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.platformDisplayName,
                      style: getTextStyle(
                        color: Colors.white,
                        fontsize: 16,
                        fontweight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: getTextStyle(
                        color: const Color(0xFFB71C1C),
                        fontsize: 15,
                        fontweight: FontWeight.w600,
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
                      alignment: isActive
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
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
                                  ),
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
          const Divider(
            color: Color(0xFF2C2C2C),
            height: 24,
            thickness: 1,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Info elements (Turnaround Time)
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getTurnaroundText(item.defaultTurnaround),
                    style: getTextStyle(
                      color: Colors.grey,
                      fontsize: 12,
                      fontweight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              // Edit and Delete actions
              Row(
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF2C2C2C)),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF2C2C2C)),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: Color(0xFFB71C1C),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTurnaroundText(String value) {
    switch (value) {
      case 'THIRTY_MIN':
        return '30 min';
      case 'ONE_HOUR':
        return '1 hr';
      case 'TWO_HOURS':
        return '2 hrs';
      case 'SIX_HOURS':
        return '6 hrs';
      case 'TWELVE_HOURS':
        return '12 hrs';
      case 'TWENTY_FOUR_HOURS':
        return '24 hrs';
      default:
        return value;
    }
  }
}
