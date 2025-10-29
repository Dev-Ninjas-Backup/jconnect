import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import '../controller/dispute_controller.dart';
import '../model/dispute_model.dart';

class RaiseDisputeDialog extends StatelessWidget {
  final DisputeController controller;

  const RaiseDisputeDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final orderList = ['Music Review Deal', 'Promotion Deal', 'Podcast Ad'];
    final selectedOrder = RxnString();
    final issueController = TextEditingController();
    final resolutionController = TextEditingController();

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
                  dropdownColor: AppColors.backGroundColor,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                  initialValue: selectedOrder.value,
                  items: orderList
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, style: getTextStyle()),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => selectedOrder.value = val,
                ),
              ),
              SizedBox(height: 15.h),
              Text('Describe the Issue', style: getTextStyle()),
              SizedBox(height: 6.h),
              TextField(
                controller: issueController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Explain what went wrong...',
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
              ),
              SizedBox(height: 15.h),
              Text('Preferred Resolution', style: getTextStyle()),
              SizedBox(height: 6.h),
              TextField(
                controller: resolutionController,
                decoration: InputDecoration(
                  hintText: 'Explain what you want for resolution',
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: CustomPrimaryButton(
                  buttonText: 'Submit Dispute',
                  onTap: () {
                    if (selectedOrder.value != null &&
                        issueController.text.isNotEmpty) {
                      controller.addDispute(
                        DisputeModel(
                          userName: 'DJ Scream',
                          dealTitle: selectedOrder.value!,
                          description: issueController.text,
                          date: 'Today',
                          amount: 85,
                          status: 'Pending',
                        ),
                      );
                      Get.back();
                    } else {
                      EasyLoading.showError('Please fill required fields');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
