import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/custom_textfield.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/core/common/widgets/custom_secondary_button.dart';
import 'package:jconnect/core/common/widgets/gradient_border_container.dart';
import 'package:jconnect/features/home/by_social_post/controller/social_buy_post_controller.dart';
import 'package:jconnect/features/home/by_social_post/widgets/buy_social_post_dialog.dart';

class BuySocialPost extends StatelessWidget {
  final SocialBuyPostController controller = Get.put(SocialBuyPostController());
  BuySocialPost({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 74.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar2(
                title: "Buy Social Post",
                leadingIconUrl: Iconpath.backIcon,
                onLeadingTap: () {
                  Get.back();
                },
              ),
              SizedBox(height: 40.h),
              Text(
                "Buy a Social Post",
                style: getTextStyle(
                  fontsize: sp(16),
                  fontweight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),

              Text("Service Name", style: getTextStyle(fontsize: sp(12))),
              SizedBox(height: 12.h),
              CustomTextfield(
                hintText: "Choose what you need help with",
                controller: controller.serviceNameController,
              ),
              SizedBox(height: 24.h),

              Text("Platform", style: getTextStyle(fontsize: sp(12))),
              SizedBox(height: 12.h),
              CustomTextfield(
                hintText: "Instagram",
                controller: controller.platformNameController,
              ),
              SizedBox(height: 24.h),
              Text("Artist Name", style: getTextStyle(fontsize: sp(12))),
              SizedBox(height: 12.h),
              CustomTextfield(
                hintText: "DJ NovaX",
                controller: controller.artistsNameController,
              ),
              SizedBox(height: 24.h),
              Text("Price", style: getTextStyle(fontsize: sp(12))),
              SizedBox(height: 12.h),
              CustomTextfield(
                hintText: "\$50",
                controller: controller.priceController,
              ),
              SizedBox(height: 8.h),
              Text(
                "Includes a 10% platform service fee.",
                style: getTextStyle(
                  fontsize: sp(8),
                  color: AppColors.primaryTextColor.withValues(alpha: .5),
                ),
              ),

              SizedBox(height: 24.h),
              Text("Attach Files", style: getTextStyle(fontsize: sp(12))),

              SizedBox(height: 12.h),
              Center(
                child: GestureDetector(
                  onTap: () {
                    controller.pickImageFromGallery();
                  },
                  child: DottedBorder(
                    options: RectDottedBorderOptions(
                      color: AppColors.primaryTextColor.withValues(alpha: .3),
                      dashPattern: [6, 6],
                      strokeWidth: .9,
                      padding: EdgeInsets.all(16),
                    ),

                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,

                        children: [
                          Image.asset(
                            Iconpath.uploadIcon,
                            height: 20.w,
                            width: 25.w,
                          ),
                          Center(
                            child: Text(
                              "Upload track, visual, or promo asset MP3, MP4, JPG, PNG up to 50MB",

                              textAlign: TextAlign.center,
                              style: getTextStyle(
                                fontsize: sp(12),
                                color: AppColors.primaryTextColor.withValues(
                                  alpha: .4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24.h),
              Text(
                "Preferred Delivery Date",
                style: getTextStyle(fontsize: sp(12)),
              ),
              SizedBox(height: 12.h),
              GradientBorderContainer(
                borderRadius: 6.r,
                borderWidth: 0.6,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.5.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "mm/dd/yyyy",
                        style: getTextStyle(
                          fontsize: sp(12),
                          fontweight: FontWeight.w400,
                          color: AppColors.primaryTextColor.withValues(
                            alpha: .5,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Icon(
                          Icons.calendar_month,
                          size: sp(20),
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text("Special Notes", style: getTextStyle(fontsize: sp(12))),

              SizedBox(height: 12.h),
              CustomTextfield(
                hintText:
                    "Use caption: Check out this new drop 🔥 #NewMusic #Promo",
                controller: controller.spacialNoteController,
              ),

              SizedBox(height: 40.h),
              CustomPrimaryButton(buttonText: "Send Request", onTap: () {showDeleteDialogBuySocialPost();}),
              SizedBox(height: 18.h),
              CustomSecondaryButton(buttonText: "Cancel", onTap: () {}),
              SizedBox(height: 10.h),
              Center(
                child: Text(
                  "You’ll be notified once the artist responds with a quote.",
                  textAlign: TextAlign.center,
                  style: getTextStyle(
                    fontsize: sp(10),
                    color: AppColors.primaryTextColor.withValues(alpha: .4),
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
