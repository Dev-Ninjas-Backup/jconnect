import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/widgets/custom_image_widget.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/my_orders/model/order_model.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  const OrderCard({super.key, required this.order});

  String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('MMM d, yyyy · h:mm a').format(dt);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (order.status) {
      case 'Active':
        statusColor = Colors.blue;
        break;
      case 'Payment Confirmation':
        statusColor = Colors.amber;
        break;
      case 'Completed':
        statusColor = Colors.green;
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        break;
      case ' Pending':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    // 'Received' = from my_service_orders API (you are the seller)
    // 'Purchased' = from my-orders API (you are the buyer)
    final bgColor = order.type == 'Received'
        ? const Color(0xFF1A1A2E) // deep blue tint for service orders
        : const Color(0xFF0D2A1B); // deep green tint for paid orders
    final borderColor = order.type == 'Received'
        ? Colors.blueAccent.withValues(alpha: 0.4)
        : Colors.greenAccent.withValues(alpha: 0.4);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                CustomImageWidget(
                  urlOrPath: order.sellerImageUrl,
                  width: 40.w,
                  height: 40.w,
                  isCircle: true,
                ),

                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (order.sellerUsername.isNotEmpty) ...[
                        Text(
                          '@${order.sellerUsername}',
                          style: getTextStyle(
                            color: AppColors.secondaryTextColor,
                            fontsize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        order.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: getTextStyle(
                          color: AppColors.primaryTextColor,
                          fontweight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        order.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: getTextStyle(color: AppColors.secondaryTextColor),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.circle, size: 14, color: statusColor),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              order.status,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: getTextStyle(color: statusColor, fontsize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '\$${(order.price).toStringAsFixed(2)}',
                  style: getTextStyle(
                    color: AppColors.primaryTextColor,
                    fontweight: FontWeight.w600,
                    fontsize: 15,
                  ),
                ),
              ],
            ),
          ),
          if (order.createdAt.isNotEmpty)
            Positioned(
              bottom: 8.h,
              right: 12.w,
              child: Text(
                _formatDate(order.createdAt),
                style: getTextStyle(
                  color: AppColors.secondaryTextColor,
                  fontsize: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
