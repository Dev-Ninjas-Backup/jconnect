import 'package:flutter/material.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/features/my_orders/order_details/model/order_details_model.dart';

class OrderTimelineWidget extends StatelessWidget {
  final List<TimelineStep> timeline;

  const OrderTimelineWidget({super.key, required this.timeline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E20),
        borderRadius: BorderRadius.circular(12),
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
                              ? Colors.redAccent
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 2),
                        ),
                        child: step.isCompleted
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              )
                            : null,
                      ),
                      if (!isLast)
                        Container(width: 2, height: 35, color: Colors.white24),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            step.title,
                            style: getTextStyle(
                              color: AppColors.primaryTextColor,
                              fontweight: FontWeight.w500,
                            ),
                          ),
                          if (step.dateTime.isNotEmpty)
                            Text(
                              step.dateTime,
                              style: getTextStyle(
                                color: AppColors.secondaryTextColor,
                                fontsize: 12,
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
