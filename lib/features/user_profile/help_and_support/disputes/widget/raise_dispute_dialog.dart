import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import '../controller/dispute_controller.dart';

class RaiseDisputeDialog extends StatelessWidget {
  final DisputeController controller;

  const RaiseDisputeDialog({super.key, required this.controller});

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      controller.proofImage.value = File(pickedFile.path);
    }
  }

  Future<void> submitDispute() async {
    if (controller.selectedOrderId.value == null ||
        controller.issueController.value.text.isEmpty) {
      EasyLoading.showError('Please fill required fields');
      return;
    }

    EasyLoading.show(status: 'Submitting...');

    // Wait for the result
    await controller.raiseDispute(
      orderId: controller.selectedOrderId.value!,
      description: controller.issueController.value.text,
      proofImage: controller.proofImage.value,
    );

    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.backGroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Raise a Dispute', style: getTextStyle()),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text('Select Order / Deal', style: getTextStyle()),
              SizedBox(height: 6.h),
              Obx(
                () => DropdownButtonFormField<String>(
                  dropdownColor: Colors.grey,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                  initialValue: controller.selectedOrderId.value,
                  items: controller.orders
                      .map(
                        (o) => DropdownMenuItem(
                          value: o['id'].toString(),
                          child: Text(
                            '${o['orderCode']}',
                            style: getTextStyle(),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => controller.selectedOrderId.value = val,
                ),
              ),
              SizedBox(height: 15.h),
              Text('Describe the Issue', style: getTextStyle()),
              SizedBox(height: 6.h),
              Obx(
                () => TextField(
                  controller: controller.issueController.value,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Explain what went wrong...',
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                  style: TextStyle(color: AppColors.primaryTextColor),
                ),
              ),
              SizedBox(height: 15.h),
              Text('Attach Proof (Image)', style: getTextStyle()),
              SizedBox(height: 6.h),
              Obx(
                () => GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    height: 150.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: controller.proofImage.value != null
                        ? Image.file(
                            controller.proofImage.value!,
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Text(
                              'Tap to upload image',
                              style: getTextStyle(),
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: CustomPrimaryButton(
                  buttonText: 'Submit Dispute',
                  onTap: submitDispute,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
