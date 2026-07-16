import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/features/payment/model/payment_model.dart';
import 'package:jconnect/features/payment/payment_controller.dart';

class AddStripe extends StatelessWidget {
  AddStripe({super.key});
  final controller = Get.put(PaymentController());

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
                title: 'Payment Method',
                leadingIconUrl: Iconpath.backIcon,
                onLeadingTap: () => Get.back(),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  }

                  final card = controller.paymentMethod.value;
                  final hasCard = card != null;

                  if (hasCard) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 24.h),
                          
                          Text(
                            'Your Active Card',
                            style: getTextStyle(
                              fontsize: 16,
                              fontweight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          
                          SizedBox(height: 12.h),
                          
                          _buildCreditCard(context, card),
                          
                          SizedBox(height: 32.h),
                          
                          // Instructions or details under the card
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.06),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      color: const Color(0xFFBB0224),
                                      size: 20.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Card Management',
                                      style: getTextStyle(
                                        fontsize: 15,
                                        fontweight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'This card is securely linked to your account via Stripe. You can make payments, and if you wish to change or remove this payment method, please tap the remove icon on the card above.',
                                  style: getTextStyle(
                                    fontsize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: 24.h),
                        ],
                      ),
                    );
                  }

                  // No card, show centered content
                  return Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildEmptyCardPlaceholder(context),
                            
                            SizedBox(height: 32.h),
                            
                            Text(
                              'Connect Your Stripe Account',
                              style: getTextStyle(
                                color: AppColors.primaryTextColor,
                                fontsize: 20,
                                fontweight: FontWeight.bold,
                              ),
                            ),
                            
                            SizedBox(height: 8.h),
                            
                            Text(
                              'Secure payouts and checkouts are processed through Stripe. Add your credit or debit card to start.',
                              style: getTextStyle(
                                fontsize: 14,
                                color: Colors.white70,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            
                            SizedBox(height: 32.h),
                            
                            CustomPrimaryButton(
                              buttonText: 'Add Payment Card',
                              buttonHeight: 52.h,
                              onTap: () {
                                controller.addCard(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
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
              'No Linked Payment Method',
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

  void _confirmDeleteCard(BuildContext context, String? cardId) {
    Get.defaultDialog(
      title: 'Remove Card',
      middleText: 'This card will be removed permanently.',
      backgroundColor: const Color(0xFF161616),
      titleStyle: getTextStyle(fontsize: 16, fontweight: FontWeight.bold, color: Colors.white),
      middleTextStyle: getTextStyle(fontsize: 14, color: Colors.white70),
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      cancelTextColor: Colors.white70,
      confirmTextColor: Colors.white,
      buttonColor: AppColors.redColor,
      onConfirm: () {
        Get.back();
        controller.deleteMethod(cardId);
      },
    );
  }
}
