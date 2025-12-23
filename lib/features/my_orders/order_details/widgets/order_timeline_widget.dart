import 'package:flutter/material.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/features/my_orders/order_details/model/order_timeline_step.dart';

class OrderTimelineWidget extends StatelessWidget {
  final List<OrderTimelineStep> timeline;

  const OrderTimelineWidget({super.key, required this.timeline});

  String _formatDateShort(String iso) {
    try {
      final dt = DateTime.parse(iso);
      // Build a short readable representation: "dd MMM • hh:mm a"
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final day = dt.day.toString().padLeft(2, '0');
      final month = months[dt.month - 1];
      int hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$day $month • $hour:$minute $ampm';
    } catch (_) {
      // If parsing fails return the original (or truncated) string
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backGroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryTextColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(timeline.length, (index) {
          final step = timeline[index];
          final isLast = index == timeline.length - 1;
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: step.isCompleted
                              ? AppColors.redColor
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 2),
                        ),
                        child: step.isCompleted
                            ? Icon(Icons.check, color: Colors.white, size: 12)
                            : null,
                      ),
                      if (!isLast)
                        Container(width: 2, height: 35, color: Colors.white24),
                    ],
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Title on the left — allow up to 2 lines to keep original design
                          Expanded(
                            child: Text(
                              step.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: getTextStyle(
                                color: AppColors.primaryTextColor,
                                fontweight: FontWeight.w500,
                              ),
                            ),
                          ),
                          // Timestamp on the right — format shortened to avoid overflow
                          if (step.dateTime.isNotEmpty)
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 140),
                              child: Text(
                                _formatDateShort(step.dateTime),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                                style: getTextStyle(
                                  color: AppColors.secondaryTextColor,
                                  fontsize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}
