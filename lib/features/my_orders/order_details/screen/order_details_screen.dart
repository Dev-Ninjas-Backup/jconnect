import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/features/my_orders/controller/my_order_controller.dart';
import 'package:jconnect/features/my_orders/order_details/controller/order_details_controller.dart';
import 'package:jconnect/features/my_orders/order_details/widgets/order_timeline_widget.dart';
import 'package:jconnect/features/my_orders/order_details/widgets/reviewer_details_widget.dart';
import 'package:jconnect/features/my_orders/order_details/widgets/review_popup.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderDetailsController());
    final orderController = Get.find<MyOrdersController>();

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
                onLeadingTap: () async {
                  // Refresh orders list before going back
                  try {
                    await orderController.loadOrders();
                  } catch (_) {}
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
                            '\$${(order.platformFee / 100).toStringAsFixed(2)}',
                          ),
                          Divider(
                            color: AppColors.secondaryTextColor.withValues(
                              alpha: .4,
                            ),
                            height: 20,
                          ),
                          _buildDetailRow(
                            'Total',
                            '\$${((order.servicePrice + order.platformFee) / 100).toStringAsFixed(2)}',
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
                    OrderTimelineWidget(
                      timeline: order.timeline,
                      proofUrl: order.proofUrl,
                    ),
                  ],
                );
              }),
              SizedBox(height: 18),
              Obx(() {
                final order = controller.order.value;
                if (order == null) return const SizedBox.shrink();

                // If order is PENDING we may show both Receive and Cancel buttons
                if (order.status == 'PENDING') {
                  return FutureBuilder<String?>(
                    future: (() {
                      try {
                        return Get.find<SharedPreferencesHelperController>()
                            .getUserId();
                      } catch (_) {
                        // Ensure the SharedPreferences controller exists
                        return Get.put(
                          SharedPreferencesHelperController(),
                        ).getUserId();
                      }
                    })(),
                    builder: (context, snapshot) {
                      final loggedInUserId = snapshot.data;
                      final isBuyer =
                          loggedInUserId != null &&
                          loggedInUserId == order.buyerId;

                      final showReceive = !isBuyer;

                      if (showReceive) {
                        // Show both Receive and Cancel side-by-side
                        return Row(
                          children: [
                            Expanded(
                              child: CustomPrimaryButton(
                                buttonText: 'Receive Order',
                                onTap: () async {
                                  await orderController.updateOrderStatus(
                                    orderId: order.id.toString(),
                                    status: OrderStatus.IN_PROGRESS,
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: CustomPrimaryButton(
                                buttonText: 'Cancel Order',
                                onTap: () async {
                                  await orderController.updateOrderStatus(
                                    orderId: order.id.toString(),
                                    status: OrderStatus.CANCELLED,
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }

                      // If buyer, only show Cancel button (they requested cancel kept)
                      return CustomPrimaryButton(
                        buttonText: 'Cancel Order',
                        onTap: () async {
                          await orderController.updateOrderStatus(
                            orderId: order.id.toString(),
                            status: OrderStatus.CANCELLED,
                          );
                        },
                      );
                    },
                  );
                }

                // For IN_PROGRESS: show Upload Proof (for seller) and Cancel
                if (order.status == 'IN_PROGRESS') {
                  return FutureBuilder<String?>(
                    future: (() {
                      try {
                        return Get.find<SharedPreferencesHelperController>()
                            .getUserId();
                      } catch (_) {
                        return Get.put(
                          SharedPreferencesHelperController(),
                        ).getUserId();
                      }
                    })(),
                    builder: (context, snapshot) {
                      final loggedInUserId = snapshot.data;
                      final isBuyer =
                          loggedInUserId != null &&
                          loggedInUserId == order.buyerId;

                      // Seller (not buyer) can upload proof
                      if (!isBuyer) {
                        return Row(
                          children: [
                            Expanded(
                              child: CustomPrimaryButton(
                                buttonText: 'Upload Proof',
                                onTap: () async {
                                  final picker = ImagePicker();
                                  final picked = await picker.pickImage(
                                    source: ImageSource.gallery,
                                  );
                                  if (picked == null) return;
                                  final file = File(picked.path);
                                  final success = await controller.uploadProof(
                                    file,
                                  );
                                  if (success) {
                                    // timeline updated by controller
                                    Get.snackbar('Success', 'Proof uploaded');
                                    // Refresh orders list in My Orders screen
                                    try {
                                      await orderController.loadOrders();
                                    } catch (_) {}
                                  }
                                },
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: CustomPrimaryButton(
                                buttonText: 'Cancel Order',
                                onTap: () async {
                                  await orderController.updateOrderStatus(
                                    orderId: order.id.toString(),
                                    status: OrderStatus.CANCELLED,
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }

                      // Buyer sees only Cancel
                      return CustomPrimaryButton(
                        buttonText: 'Cancel Order',
                        onTap: () async {
                          await orderController.updateOrderStatus(
                            orderId: order.id.toString(),
                            status: OrderStatus.CANCELLED,
                          );
                        },
                      );
                    },
                  );
                }

                // For PROOF_SUBMITTED: show Confirm Order and Reject Proof (for buyer) and Cancel
                if (order.status == 'PROOF_SUBMITTED') {
                  return FutureBuilder<String?>(
                    future: (() {
                      try {
                        return Get.find<SharedPreferencesHelperController>()
                            .getUserId();
                      } catch (_) {
                        return Get.put(
                          SharedPreferencesHelperController(),
                        ).getUserId();
                      }
                    })(),
                    builder: (context, snapshot) {
                      final loggedInUserId = snapshot.data;
                      final isBuyer =
                          loggedInUserId != null &&
                          loggedInUserId == order.buyerId;

                      // Buyer can confirm or reject order
                      if (isBuyer) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: CustomPrimaryButton(
                                    buttonText: 'Confirm Order',
                                    onTap: () async {
                                      final success = await controller
                                          .confirmOrder();
                                      if (success) {
                                        EasyLoading.showSuccess(
                                          'Order confirmed & payment released',
                                        );
                                        // Refresh orders list in My Orders screen
                                        try {
                                          await orderController.loadOrders();
                                        } catch (_) {}
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            // Show Reject Proof button only if proof has not been rejected yet (isCancalProofSubmitted = false)
                            if (!order.isCancalProofSubmitted)
                              Column(
                                children: [
                                  SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CustomPrimaryButton(
                                          buttonText: 'Reject Proof',
                                          onTap: () async {
                                            final success = await controller
                                                .rejectProof();
                                            if (success) {
                                              EasyLoading.showSuccess(
                                                'Proof rejected. Seller can now re-submit.',
                                              );
                                              // Refresh orders list in My Orders screen
                                              try {
                                                await orderController
                                                    .loadOrders();
                                              } catch (_) {}
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                          ],
                        );
                      }

                      // Seller can re-upload proof if it was rejected (isCancalProofSubmitted)
                      if (!isBuyer && order.isCancalProofSubmitted) {
                        return Row(
                          children: [
                            Expanded(
                              child: CustomPrimaryButton(
                                buttonText: 'Upload Proof',
                                onTap: () async {
                                  final picker = ImagePicker();
                                  final picked = await picker.pickImage(
                                    source: ImageSource.gallery,
                                  );
                                  if (picked == null) return;
                                  final file = File(picked.path);
                                  final success = await controller.uploadProof(
                                    file,
                                  );
                                  if (success) {
                                    // timeline updated by controller
                                    Get.snackbar('Success', 'Proof uploaded');
                                    // Refresh orders list in My Orders screen
                                    try {
                                      await orderController.loadOrders();
                                    } catch (_) {}
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      }

                      // Seller sees nothing (no buttons for seller on PROOF_SUBMITTED unless proof was rejected)
                      return const SizedBox.shrink();
                    },
                  );
                }

                // For RELEASED status: no buttons for anyone
                if (order.status == 'RELEASED') {
                  return FutureBuilder<String?>(
                    future: (() {
                      try {
                        final prefs =
                            Get.find<SharedPreferencesHelperController>();
                        return prefs.getUserId();
                      } catch (_) {
                        return Get.put(
                          SharedPreferencesHelperController(),
                        ).getUserId();
                      }
                    })(),
                    builder: (context, snapshot) {
                      final loggedInUserId = snapshot.data;
                      final isBuyer =
                          loggedInUserId != null &&
                          loggedInUserId == order.buyerId;

                      // Buyer can post a review
                      if (isBuyer) {
                        return CustomPrimaryButton(
                          buttonText: 'Post Review',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => ReviewPopup(
                                onSubmit: (rating, reviewText) async {
                                  final success = await controller.postReview(
                                    rating: rating,
                                    reviewText: reviewText,
                                  );
                                  if (success) {
                                    Get.snackbar(
                                      'Success',
                                      'Review posted successfully!',
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white,
                                    );
                                    // Refresh orders list in My Orders screen
                                    try {
                                      await orderController.loadOrders();
                                    } catch (_) {}
                                  }
                                },
                              ),
                            );
                          },
                        );
                      }

                      // Seller sees nothing on RELEASED
                      return const SizedBox.shrink();
                    },
                  );
                }

                // For other non-PENDING statuses show the Cancel button as before
                // Do not show cancel button if the order is already CANCELLED
                if (order.status.toUpperCase() == 'CANCELLED') {
                  return const SizedBox.shrink();
                }

                return CustomPrimaryButton(
                  buttonText: 'Cancel Order',
                  onTap: () async {
                    await orderController.updateOrderStatus(
                      orderId: order.id.toString(),
                      status: OrderStatus.CANCELLED,
                    );
                  },
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
