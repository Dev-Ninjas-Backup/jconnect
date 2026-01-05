import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/features/my_orders/order_details/controller/order_details_controller.dart';
import 'package:jconnect/features/my_orders/order_details/widgets/order_timeline_widget.dart';
import 'package:jconnect/features/my_orders/order_details/widgets/reviewer_details_widget.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderDetailsController());

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,

      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 74, horizontal: 16),
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
              SizedBox(height: 32),
              Obx(() {
                final order = controller.order.value;
                if (order == null) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReviewerDetails(order: order),
                    SizedBox(height: 24),

                    Text(
                      'Order Details',
                      style: getTextStyle(
                        color: AppColors.primaryTextColor,
                        fontweight: FontWeight.w600,
                        fontsize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.backGroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.secondaryTextColor),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('Order ID', order.orderCode),
                          _buildDetailRow('Order Created', order.orderCreated),
                          _buildDetailRow('Delivery Date', order.deliveryDate),
                          _buildDetailRow(
                            'Service Price',
                            '\$${(order.servicePrice / 100).toStringAsFixed(2)}',
                          ),
                          _buildDetailRow(
                            'Platform Fee (${order.platformRate}%)',
                            '\$${order.platformFee.toStringAsFixed(2)}',
                          ),
                          Divider(
                            color: AppColors.secondaryTextColor.withValues(
                              alpha: .4,
                            ),
                            height: 20,
                          ),
                          _buildDetailRow(
                            'Total',
                            '\$${(order.total / 100).toStringAsFixed(2)}'
,
                            isBold: true,
                          ),
                          SizedBox(height: 12),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Color(0xFF353434),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.verified_user,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                SizedBox(width: 10),
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
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Secured by',
                                style: getTextStyle(
                                  color: Colors.white38,
                                  fontsize: 11,
                                  fontweight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(width: 8),
                              Image.asset(Iconpath.stripeIcon),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    Text(
                      'Order Timeline',
                      style: getTextStyle(
                        color: AppColors.primaryTextColor,
                        fontweight: FontWeight.w600,
                        fontsize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    OrderTimelineWidget(timeline: order.timeline),
                  ],
                );
              }),
              SizedBox(height: 18),
              CustomPrimaryButton(buttonText: 'Cancel Order', onTap: () {}),
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
