import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_image_widget.dart';
import 'package:jconnect/features/my_orders/model/order_model.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  const OrderCard({super.key, required this.order});

  String _formatDateTime(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('MMM d, yyyy · h:mm a').format(dt);
    } catch (_) {
      return raw;
    }
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 60) {
        final mins = diff.inMinutes <= 0 ? 1 : diff.inMinutes;
        return '$mins ${mins == 1 ? 'min' : 'mins'} ago';
      } else if (diff.inHours < 24) {
        final hrs = diff.inHours;
        return '$hrs ${hrs == 1 ? 'hr' : 'hrs'} ago';
      } else if (diff.inDays < 30) {
        final days = diff.inDays;
        return '$days ${days == 1 ? 'day' : 'days'} ago';
      } else if (diff.inDays < 365) {
        final months = (diff.inDays / 30).floor();
        final m = months <= 0 ? 1 : months;
        return '$m ${m == 1 ? 'month' : 'months'} ago';
      } else {
        final years = (diff.inDays / 365).floor();
        final y = years <= 0 ? 1 : years;
        return '$y ${y == 1 ? 'year' : 'years'} ago';
      }
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isReceived = order.type == 'Received';

    final accentColor = isReceived
        ? const Color(0xFF3B82F6) // Vibrant Blue accent for Orders Received
        : const Color(0xFF22C55E); // Vibrant Green accent for Orders Purchased

    final bgColor = isReceived
        ? const Color(0xFF0F172A) // Dark slate navy tint
        : const Color(0xFF09160F); // Dark emerald green tint

    final borderColor = isReceived
        ? const Color(0xFF1E293B)
        : const Color(0xFF143823);

    final roleLabel = isReceived ? 'Buyer' : 'Creator';

    String handle = order.sellerUsername.trim();
    if (handle.isNotEmpty) {
      if (!handle.startsWith('@')) handle = '@$handle';
    } else if (order.sellerName.trim().isNotEmpty) {
      handle = order.sellerName.trim();
    }

    Color statusColor;
    IconData statusIcon;
    final statusLower = order.status.toLowerCase().trim();

    if (statusLower.contains('completed') || statusLower.contains('proof')) {
      statusColor = const Color(0xFF22C55E);
      statusIcon = Icons.check_circle_rounded;
    } else if (statusLower.contains('cancel')) {
      statusColor = const Color(0xFFEF4444);
      statusIcon = Icons.cancel_outlined;
    } else if (statusLower.contains('payment') ||
        statusLower.contains('pending')) {
      statusColor = const Color(0xFFF59E0B);
      statusIcon = Icons.access_time_rounded;
    } else {
      statusColor = accentColor;
      statusIcon = Icons.access_time_rounded;
    }

    final dateToUse = order.updatedAt.isNotEmpty
        ? order.updatedAt
        : order.createdAt;
    final formattedDateTime = _formatDateTime(dateToUse);
    final formattedAgo = _formatDate(dateToUse);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left vertical accent strip
              Container(width: 4.w, color: accentColor),
              // Main card details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomImageWidget(
                        urlOrPath: order.sellerImageUrl,
                        width: 46.w,
                        height: 46.w,
                        isCircle: true,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              order.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: getTextStyle(
                                color: AppColors.primaryTextColor,
                                fontweight: FontWeight.w600,
                                fontsize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            if (handle.isNotEmpty) ...[
                              Text(
                                '$roleLabel: $handle',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: getTextStyle(
                                  color: const Color(0xFF94A3B8),
                                  fontsize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                            ],
                            if (order.description != null &&
                                order.description!.trim().isNotEmpty) ...[
                              Text(
                                order.description!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: getTextStyle(
                                  color: const Color(0xFF64748B),
                                  fontsize: 11,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                            Row(
                              children: [
                                Icon(statusIcon, size: 13, color: statusColor),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    order.status.toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: getTextStyle(
                                      color: statusColor,
                                      fontweight: FontWeight.bold,
                                      fontsize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (formattedDateTime.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                '${order.statusMessage} · $formattedDateTime${formattedAgo.isNotEmpty ? " ($formattedAgo)" : ""}',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: getTextStyle(
                                  color: const Color(0xFF64748B),
                                  fontsize: 10,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${order.price.toStringAsFixed(2)}',
                            style: getTextStyle(
                              color: AppColors.primaryTextColor,
                              fontweight: FontWeight.bold,
                              fontsize: 14,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Color(0xFF64748B),
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
