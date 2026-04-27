// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/features/my_orders/controller/my_order_controller.dart';
import 'package:jconnect/features/my_orders/order_details/controller/order_details_controller.dart';
import 'package:jconnect/features/my_orders/order_details/widgets/order_timeline_widget.dart';
import 'package:jconnect/features/my_orders/order_details/widgets/reviewer_details_widget.dart';
import 'package:jconnect/features/my_orders/order_details/widgets/review_popup.dart';
import 'package:intl/intl.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  /// Pick any file type and show confirmation dialog before uploading
  Future<void> _pickAndConfirmProofUpload(
    BuildContext context,
    OrderDetailsController controller,
    MyOrdersController orderController,
  ) async {
    Future<void> _selectFile() async {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'mp4', 'jpg', 'jpeg', 'png', 'gif', 'pdf', 'mov', 'avi', 'flv', 'wav', 'aac'],
      );
      
      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      final ext = fileName.split('.').last.toLowerCase();
      final isImage = ['jpg', 'jpeg', 'png', 'gif'].contains(ext);

      // Show confirmation dialog
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (dialogContext) => Dialog(
          backgroundColor: AppColors.backGroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.secondaryTextColor),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Confirm Upload',
                    style: getTextStyle(
                      color: AppColors.primaryTextColor,
                      fontweight: FontWeight.w600,
                      fontsize: 16,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Show image preview or file icon
                  if (isImage)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 280,
                          maxWidth: 300,
                        ),
                        child: Image.file(file, fit: BoxFit.contain),
                      ),
                    )
                  else
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.backGroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.secondaryTextColor),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _getFileIcon(ext),
                            size: 64,
                            color: AppColors.primaryTextColor.withValues(alpha: 0.6),
                          ),
                          SizedBox(height: 12),
                          Text(
                            fileName,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: getTextStyle(
                              color: AppColors.primaryTextColor,
                              fontsize: 12,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${ext.toUpperCase()} • ${(file.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB',
                            style: getTextStyle(
                              color: AppColors.secondaryTextColor,
                              fontsize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 20),
                  Text(
                    'Are you sure you want to upload this proof?',
                    style: getTextStyle(
                      color: AppColors.secondaryTextColor,
                      fontsize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext); // Close dialog
                            // Offer to reselect
                            _selectFile(); // Recursively call to pick again
                          },
                          child: Text(
                            'Reselect',
                            style: getTextStyle(
                              color: AppColors.redColor,
                              fontweight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            Navigator.pop(dialogContext); // Close dialog
                            // Proceed with upload
                            final success = await controller.uploadProof(file);
                            if (success) {
                              Get.snackbar('Success', 'Proof uploaded');
                              try {
                                await orderController.loadOrders();
                              } catch (_) {}
                            }
                          },
                          child: Text(
                            'Confirm',
                            style: getTextStyle(
                              color: AppColors.redColor,
                              fontweight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Start the selection process
    await _selectFile();
  }

  /// Get file icon based on extension
  IconData _getFileIcon(String ext) {
    if (['mp3', 'wav', 'aac'].contains(ext)) {
      return Icons.audio_file;
    } else if (['mp4', 'mov', 'avi', 'flv'].contains(ext)) {
      return Icons.video_library;
    } else if (ext == 'pdf') {
      return Icons.picture_as_pdf;
    }
    return Icons.insert_drive_file;
  }

  @override
  Widget build(BuildContext context) {
    // Delete previous instance and create a fresh one for each order
    // The onReady() callback will ensure arguments are properly read
    if (Get.isRegistered<OrderDetailsController>()) {
      Get.delete<OrderDetailsController>(force: true);
    }
    final controller = Get.put(OrderDetailsController());
    final orderController = Get.find<MyOrdersController>();

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(right: 16, left: 16, top: 74, bottom: 60),
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
                          _buildDetailRow(
                            'Order Created',
                            _formatDate(order.orderCreated),
                          ),
                          _buildDetailRow(
                            'Delivery Date',
                            _formatDate(order.deliveryDate),
                          ),
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
                                  EasyLoading.show(status: 'Cancelling...');
                                  try {
                                    await orderController.updateOrderStatus(
                                      orderId: order.id.toString(),
                                      status: OrderStatus.CANCELLED,
                                    );
                                  } finally {
                                    EasyLoading.dismiss();
                                  }
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
                          EasyLoading.show(status: 'Cancelling...');
                          try {
                            await orderController.updateOrderStatus(
                              orderId: order.id.toString(),
                              status: OrderStatus.CANCELLED,
                            );
                          } finally {
                            EasyLoading.dismiss();
                          }
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
                                onTap: () => _pickAndConfirmProofUpload(
                                  context,
                                  controller,
                                  orderController,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: CustomPrimaryButton(
                                buttonText: 'Cancel Order',
                                onTap: () async {
                                  EasyLoading.show(status: 'Cancelling...');
                                  try {
                                    await orderController.updateOrderStatus(
                                      orderId: order.id.toString(),
                                      status: OrderStatus.CANCELLED,
                                    );
                                  } finally {
                                    EasyLoading.dismiss();
                                  }
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
                          EasyLoading.show(status: 'Cancelling...');
                          try {
                            await orderController.updateOrderStatus(
                              orderId: order.id.toString(),
                              status: OrderStatus.CANCELLED,
                            );
                          } finally {
                            EasyLoading.dismiss();
                          }
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
                            SizedBox(height: 12),
                            CustomPrimaryButton(
                              buttonText: 'Cancel Order',
                              onTap: () async {
                                EasyLoading.show(status: 'Cancelling...');
                                try {
                                  await orderController.updateOrderStatus(
                                    orderId: order.id.toString(),
                                    status: OrderStatus.CANCELLED,
                                  );
                                } finally {
                                  EasyLoading.dismiss();
                                }
                              },
                            ),
                          ],
                        );
                      }

                      // Seller can re-upload proof if it was rejected (isCancalProofSubmitted)
                      if (!isBuyer && order.isCancalProofSubmitted) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: CustomPrimaryButton(
                                    buttonText: 'Upload Proof',
                                    onTap: () => _pickAndConfirmProofUpload(
                                      context,
                                      controller,
                                      orderController,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            CustomPrimaryButton(
                              buttonText: 'Cancel Order',
                              onTap: () async {
                                EasyLoading.show(status: 'Cancelling...');
                                try {
                                  await orderController.updateOrderStatus(
                                    orderId: order.id.toString(),
                                    status: OrderStatus.CANCELLED,
                                  );
                                } finally {
                                  EasyLoading.dismiss();
                                }
                              },
                            ),
                          ],
                        );
                      }

                      // Seller sees Cancel button when proof is pending review
                      return CustomPrimaryButton(
                        buttonText: 'Cancel Order',
                        onTap: () async {
                          EasyLoading.show(status: 'Cancelling...');
                          try {
                            await orderController.updateOrderStatus(
                              orderId: order.id.toString(),
                              status: OrderStatus.CANCELLED,
                            );
                          } finally {
                            EasyLoading.dismiss();
                          }
                        },
                      );
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
                    EasyLoading.show(status: 'Cancelling...');
                    try {
                      await orderController.updateOrderStatus(
                        orderId: order.id.toString(),
                        status: OrderStatus.CANCELLED,
                      );
                    } finally {
                      EasyLoading.dismiss();
                    }
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('MMM d, yyyy · h:mm a').format(dt);
    } catch (_) {
      return raw;
    }
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
