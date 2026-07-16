import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/custom_textfield.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/core/common/widgets/custom_snackbar.dart';
import 'package:jconnect/features/repost/repost_process_option/controller/repost_process_option_controller.dart';
import 'package:jconnect/features/payment/payment_controller.dart';
import 'package:jconnect/features/repost/repost_process_option/screens/set_complation_time.dart';
import 'package:jconnect/features/user_profile/payment_method/add_stripe/screen/add_stripe.dart';

class RepostContentPaymentScreen extends StatelessWidget {
  final String listingId;
  const RepostContentPaymentScreen({super.key, required this.listingId});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RepostProcessOptionController>();
    final paymentController = Get.put(PaymentController());
    final selectedOption = controller.currentPlatform.repostOptions[controller.selectedOptionIndex.value];
    final shareLinkController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              CustomAppBar2(
                title: 'Content & Payment',
                leadingIconUrl: Iconpath.backIcon,
                onLeadingTap: () {
                  Get.back();
                },
              ),

              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Share Link",
                          style: getTextStyle(
                            color: AppColors.primaryTextColor,
                            fontsize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        CustomTextfield(
                          hintText: "Enter your Share Link",
                          controller: shareLinkController,
                        ),
                        const SizedBox(height: 20),

                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              final urlText = shareLinkController.text.trim();
                              if (urlText.isEmpty) {
                                showGradientSnackBar(
                                  title: 'Hi!',
                                  message: 'Please enter a share link',
                                );
                                return;
                              }
                              final uri = Uri.tryParse(urlText);
                              if (uri == null || !uri.hasAbsolutePath || !uri.scheme.startsWith('http')) {
                                showGradientSnackBar(
                                  title: 'Hi!',
                                  message: 'Please enter a valid URL address',
                                );
                                return;
                              }

                              // Check if a payment method is linked
                              if (paymentController.paymentMethod.value == null) {
                                showGradientSnackBar(
                                  title: 'Payment Method Required',
                                  message: 'Please add a payment card to continue.',
                                );
                                Get.to(() => AddStripe());
                                return;
                              }

                              final res = await controller.processPayment(listingId);
                              if (res != null) {
                                Get.to(
                                  SetCompletionTimeScreen(
                                    listingId: listingId,
                                    paymentUrl: urlText,
                                    paymentIntentId: res['paymentIntentId'] as String? ?? '',
                                    amount: res['amount'] as int? ?? 0,
                                    currency: res['currency'] as String? ?? '',
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 18.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF60000F),
                                    Color(0xFFBB0224),
                                    Color(0xFF60000F),
                                  ],
                                ),
                              ),
                              child: Text(
                                'Pay Now ${selectedOption.price}',
                                style: getTextStyle(
                                  fontsize: 14,
                                  fontweight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
