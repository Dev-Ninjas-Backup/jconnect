import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CustomAppBar2(
                title: 'Payment Method',
                leadingIconUrl: Iconpath.backIcon,
                onLeadingTap: () {
                  Get.back();
                },
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final card = controller.paymentMethod.value;
                  final hasCard = card != null;

                  if (hasCard) {
                    // Show card at the top
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Card(
                          elevation: 4,
                          child: ListTile(
                            leading: const Icon(Icons.credit_card),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${card.cardBrand?.toUpperCase() ?? 'CARD'} •••• ${card.last4 ?? '----'}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Get.defaultDialog(
                                      title: 'Delete card?',
                                      middleText:
                                          'This card will be removed permanently.',
                                      backgroundColor: Colors.black,
                                      titleStyle: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      middleTextStyle: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                      textConfirm: 'Delete',
                                      textCancel: 'Cancel',
                                      buttonColor: Colors.red,
                                      onConfirm: () {
                                        Get.back();
                                        controller.deleteMethod(card.id);
                                      },
                                    );
                                  },
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.red[400],
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              (card.expMonth != null && card.expYear != null)
                                  ? 'Expires ${card.expMonth}/${card.expYear}'
                                  : 'Expiry not available',
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  // No card, show centered content
                  return Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Connect Your Stripe Account',
                            style: getTextStyle(
                              color: AppColors.primaryTextColor,
                              fontsize: 18,
                              fontweight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Secure payouts are processed through Stripe. Connect your account to start receiving payments.',
                            style: getTextStyle(
                              fontsize: 13,
                              color: AppColors.secondaryTextColor,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 18.h),
                          CustomPrimaryButton(
                            buttonText: 'Connect With Stripe',
                            onTap: () {
                              controller.addCard(context);
                            },
                          ),
                        ],
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
}
