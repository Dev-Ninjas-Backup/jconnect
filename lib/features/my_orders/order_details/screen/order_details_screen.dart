import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/features/my_orders/order_details/controller/order_details_controller.dart';
import 'package:jconnect/features/my_orders/order_details/widgets/order_timeline_widget.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderDetailsController());

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,

      body: Padding(
        padding:  EdgeInsets.symmetric(vertical: 74, horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomAppBar2(
                title: 'Order Details',
                leadingIconUrl: Iconpath.backIcon,
                onLeadingTap: () {
                  Get.back();
                },
              ),
              Obx(() {
                final order = controller.order.value;
                if (order == null) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Header Card ---
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/icons/instagram.png',
                                    width: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    order.platform,
                                    style: getTextStyle(
                                      color: AppColors.primaryTextColor,
                                      fontweight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '\$${order.servicePrice.toStringAsFixed(0)}',
                                style: getTextStyle(
                                  color: AppColors.primaryTextColor,
                                  fontweight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                order.serviceTitle,
                                style: getTextStyle(
                                  color: AppColors.secondaryTextColor,
                                  fontsize: 13,
                                ),
                              ),
                              Text(
                                order.subServiceTitle,
                                style: getTextStyle(
                                  color: Colors.white54,
                                  fontsize: 13,
                                  fontweight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF242629),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundImage: AssetImage(
                                    order.reviewerImage,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order.reviewerName,
                                        style: getTextStyle(
                                          color: AppColors.primaryTextColor,
                                          fontweight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        order.reviewerHandle,
                                        style: getTextStyle(
                                          color: AppColors.secondaryTextColor,
                                          fontsize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      order.rating.toString(),
                                      style: getTextStyle(
                                        color: Colors.amber,
                                        fontsize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- Order Details ---
                    Text(
                      'Order Details',
                      style: getTextStyle(
                        color: AppColors.primaryTextColor,
                        fontweight: FontWeight.w600,
                        fontsize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('Order ID', order.id),
                          _buildDetailRow('Order Created', order.orderCreated),
                          _buildDetailRow('Delivery Date', order.deliveryDate),
                          _buildDetailRow(
                            'Service Price',
                            '\$${order.servicePrice.toStringAsFixed(2)}',
                          ),
                          _buildDetailRow(
                            'Platform Fee (10%)',
                            '\$${order.platformFee.toStringAsFixed(0)}',
                          ),
                          const Divider(color: Colors.white10, height: 20),
                          _buildDetailRow(
                            'Total',
                            '\$${order.total.toStringAsFixed(0)}',
                            isBold: true,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF242629),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.verified_user,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Payment is held securely until post is confirmed live.',
                                    style: getTextStyle(
                                      color: AppColors.secondaryTextColor,
                                      fontsize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Center(
                            child: Text(
                              'Secured by Stripe',
                              style: getTextStyle(
                                color: Colors.white38,
                                fontsize: 11,
                                fontweight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- Order Timeline ---
                    Text(
                      'Order Timeline',
                      style: getTextStyle(
                        color: AppColors.primaryTextColor,
                        fontweight: FontWeight.w600,
                        fontsize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    OrderTimelineWidget(timeline: order.timeline),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: getTextStyle(
              color: AppColors.secondaryTextColor,
              fontsize: 13,
            ),
          ),
          Text(
            value,
            style: getTextStyle(
              color: AppColors.primaryTextColor,
              fontweight: isBold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
