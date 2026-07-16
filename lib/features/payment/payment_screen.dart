// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'payment_controller.dart';

// class PaymentPage extends StatelessWidget {
//   PaymentPage({super.key});

//   final controller = Get.put(PaymentController());
//   final dynamic arg = Get.arguments;

//   // Demo service data
//   String get serviceId => arg.service!.id ?? '';
//   String get serviceTitle => arg.service!.serviceName ?? '';
//   final String serviceDescription = 'Get unlimited access to all features.';
//   int get servicePrice => arg.service!.price ?? 0.0;

//   @override
//   Widget build(BuildContext context) {
//     final double totalPrice =
//         servicePrice + (servicePrice * controller.platformFee.value / 100);
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         leading: const BackButton(color: Colors.white),
//         title: const Text('Payment', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.black,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Service details
//             Text(
//               serviceTitle,
//               style: const TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               serviceDescription,
//               style: const TextStyle(fontSize: 16, color: Colors.white70),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               "Platform Fee: ${controller.platformFee.value}%",
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Color.fromARGB(255, 240, 190, 105),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Price: \$${servicePrice.toStringAsFixed(2)}',
//               style: const TextStyle(fontSize: 20, color: Colors.greenAccent),
//             ),
//             SizedBox(height: 16),
//             Text(${totalPrice.toStringAsFixed(2)}',},
//               style: const TextStyle(fontSize: 20, color: Colors.greenAccent),
//             ),
//             const Spacer(),

//             // Payment button
//             Center(
//               child: Obx(
//                 () => controller.isLoading.value
//                     ? const CircularProgressIndicator()
//                     : ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 40,
//                             vertical: 16,
//                           ),
//                         ),
//                         onPressed: () => _showConfirmationDialog(context),
//                         child: const Text(
//                           'Pay Now',
//                           style: TextStyle(fontSize: 18),
//                         ),
//                       ),
//               ),
//             ),
//             SizedBox(height: 35),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Show confirmation dialog before payment
//   void _showConfirmationDialog(BuildContext context) {
//     Get.defaultDialog(
//       title: 'Confirm Payment',
//       middleText:
//           'Do you want to pay \$${servicePrice.toStringAsFixed(2)} for $serviceTitle?',
//       backgroundColor: Colors.black,
//       titleStyle: const TextStyle(color: Colors.white),
//       middleTextStyle: const TextStyle(color: Colors.white70),
//       textCancel: 'No',
//       textConfirm: 'Yes',
//       cancelTextColor: Colors.white70,
//       confirmTextColor: Colors.white,
//       buttonColor: Colors.green,
//       onConfirm: () {
//         Get.back(); // close dialog
//         controller.makePayment(serviceId);
//       },
//       onCancel: () {
//         // Do nothing
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button_2.dart';
import 'package:jconnect/features/payment/model/payment_model.dart';
import 'payment_controller.dart';

class PaymentPage extends StatelessWidget {
  PaymentPage({super.key});

  final PaymentController controller = Get.put(PaymentController());
  final dynamic arg = Get.arguments;

  String get serviceId => arg.service!.id ?? '';
  String get serviceTitle => arg.service!.serviceName ?? '';
  String get serviceRequestId => (arg.serviceRequest?.id ?? '').toString();
  final String serviceDescription = 'Get unlimited access to all features.';
  double get servicePrice => (arg.service!.price ?? 0).toDouble();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              CustomAppBar2(
                title: 'Checkout',
                leadingIconUrl: Iconpath.backIcon,
                onLeadingTap: () => Get.back(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24.h),
                      
                      // Section: Service Information
                      _buildServiceHeader(),
                      
                      SizedBox(height: 24.h),
                      
                      // Section Title: Payment Method
                      Text(
                        'Payment Method',
                        style: getTextStyle(
                          fontsize: 16,
                          fontweight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      
                      SizedBox(height: 12.h),
                      
                      // Obx for payment method state
                      Obx(() {
                        final card = controller.paymentMethod.value;
                        if (card != null) {
                          return _buildCreditCard(context, card);
                        } else {
                          return _buildEmptyCardPlaceholder(context);
                        }
                      }),
                      
                      SizedBox(height: 24.h),
                      
                      // Section: Order Summary
                      Obx(() {
                        final double platformFeePercent = controller.platformFee.value.toDouble();
                        final double feeAmount = servicePrice * platformFeePercent / 100;
                        final double totalPrice = servicePrice + feeAmount;
                        
                        return _buildOrderSummary(feeAmount, totalPrice);
                      }),
                      
                      SizedBox(height: 24.h),
                      
                      // Security Badge
                      _buildSecurityBadge(),
                      
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
              
              // Bottom Action Button Container
              Obx(() {
                final double platformFeePercent = controller.platformFee.value.toDouble();
                final double feeAmount = servicePrice * platformFeePercent / 100;
                final double totalPrice = servicePrice + feeAmount;
                final hasCard = controller.paymentMethod.value != null;
                
                return Padding(
                  padding: EdgeInsets.only(bottom: 24.h),
                  child: controller.isLoading.value
                      ? Container(
                          height: 56.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: const Center(
                            child: SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                        )
                      : CustomPrimaryButton2(
                          buttonText: hasCard 
                              ? 'Pay \$${totalPrice.toStringAsFixed(2)}' 
                              : 'Add Card & Pay',
                          buttonHeight: 56.h,
                          onTap: () {
                            if (!hasCard) {
                              controller.addCard(context);
                            } else {
                              _showConfirmationDialog(context);
                            }
                          },
                        ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFBB0224).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.business_center_outlined,
                  color: const Color(0xFFBB0224),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  serviceTitle,
                  style: getTextStyle(
                    fontsize: 18,
                    fontweight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            serviceDescription,
            style: getTextStyle(
              fontsize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCardPlaceholder(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.addCard(context),
      child: Container(
        height: 180.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_card_rounded,
                size: 32.sp,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Add Payment Card',
              style: getTextStyle(
                fontsize: 15,
                fontweight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Your details are protected by Stripe',
              style: getTextStyle(
                fontsize: 12,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCard(BuildContext context, PaymentMethodModel card) {
    final brandName = card.cardBrand?.toLowerCase() ?? 'card';
    
    return Container(
      height: 180.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3B0008),
            Color(0xFF160003),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 42.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.r),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFF6D365),
                            Color(0xFFFDA085),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    
                    Row(
                      children: [
                        Text(
                          brandName.toUpperCase(),
                          style: getTextStyle(
                            fontsize: 16,
                            fontweight: FontWeight.bold,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        GestureDetector(
                          onTap: () => _confirmDeleteCard(context, card.id),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.redAccent.shade200,
                            size: 22.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                Text(
                  '••••   ••••   ••••   ${card.last4}',
                  style: getTextStyle(
                    fontsize: 20,
                    fontweight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CARD HOLDER',
                          style: getTextStyle(
                            fontsize: 9,
                            color: Colors.white30,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'LINKED CUSTOMER',
                          style: getTextStyle(
                            fontsize: 12,
                            fontweight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'EXPIRES',
                          style: getTextStyle(
                            fontsize: 9,
                            color: Colors.white30,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${card.expMonth.toString().padLeft(2, '0')} / ${card.expYear.toString().substring(card.expYear.toString().length - 2)}',
                          style: getTextStyle(
                            fontsize: 12,
                            fontweight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(double feeAmount, double totalPrice) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: getTextStyle(
              fontsize: 16,
              fontweight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Divider(
            color: Colors.white.withValues(alpha: 0.08),
            height: 24.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price',
                style: getTextStyle(
                  fontsize: 14,
                  color: Colors.white70,
                ),
              ),
              Text(
                '\$${servicePrice.toStringAsFixed(2)}',
                style: getTextStyle(
                  fontsize: 14,
                  fontweight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Platform Fee (${controller.platformFee.value}%)',
                style: getTextStyle(
                  fontsize: 14,
                  color: Colors.white70,
                ),
              ),
              Text(
                '+\$${feeAmount.toStringAsFixed(2)}',
                style: getTextStyle(
                  fontsize: 14,
                  fontweight: FontWeight.w600,
                  color: const Color.fromARGB(255, 240, 190, 105),
                ),
              ),
            ],
          ),
          Divider(
            color: Colors.white.withValues(alpha: 0.08),
            height: 24.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: getTextStyle(
                  fontsize: 16,
                  fontweight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '\$${totalPrice.toStringAsFixed(2)}',
                style: getTextStyle(
                  fontsize: 18,
                  fontweight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityBadge() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 14.sp,
            color: Colors.white38,
          ),
          SizedBox(width: 6.w),
          Text(
            'Secure checkout powered by Stripe',
            style: getTextStyle(
              fontsize: 12,
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCard(BuildContext context, String? cardId) {
    Get.defaultDialog(
      title: 'Remove Card',
      middleText: 'Are you sure you want to remove this card?',
      backgroundColor: const Color(0xFF161616),
      titleStyle: getTextStyle(fontsize: 16, fontweight: FontWeight.bold, color: Colors.white),
      middleTextStyle: getTextStyle(fontsize: 14, color: Colors.white70),
      textCancel: 'Cancel',
      textConfirm: 'Remove',
      cancelTextColor: Colors.white70,
      confirmTextColor: Colors.white,
      buttonColor: AppColors.redColor,
      onConfirm: () {
        Get.back();
        controller.deleteMethod(cardId);
      },
    );
  }

  /// Confirmation dialog
  void _showConfirmationDialog(BuildContext context) {
    final double totalPrice =
        servicePrice + (servicePrice * controller.platformFee.value / 100);
    Get.defaultDialog(
      title: 'Confirm Payment',
      middleText:
          'Do you want to pay \$${totalPrice.toStringAsFixed(2)} for $serviceTitle?',
      backgroundColor: const Color(0xFF161616),
      titleStyle: getTextStyle(fontsize: 16, fontweight: FontWeight.bold, color: Colors.white),
      middleTextStyle: getTextStyle(fontsize: 14, color: Colors.white70),
      textCancel: 'No',
      textConfirm: 'Yes',
      cancelTextColor: Colors.white70,
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFBB0224),
      onConfirm: () {
        Get.back();
        controller.makePayment(serviceId, serviceRequestId: serviceRequestId);
      },
    );
  }
}
