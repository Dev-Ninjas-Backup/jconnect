import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import '../controller/dispute_controller.dart';
import '../widget/dispute_card_widget.dart';
import '../widget/raise_dispute_dialog.dart';

class MyDisputesScreen extends StatelessWidget {
  const MyDisputesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DisputeController controller = Get.put(DisputeController());

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backGroundColor,
        elevation: 0,
        title: Center(
          child: Text('My Disputes', style: getTextStyle(fontsize: 22)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Obx(() {
          if (controller.disputes.isEmpty) {
            return Center(
              child: Text(
                'No disputes found.',
                style: getTextStyle(fontsize: 18),
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.builder(
            itemCount: controller.disputes.length,
            itemBuilder: (context, index) {
              final dispute = controller.disputes[index];
              return DisputeCardWidget(dispute: dispute);
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.redColor,
        onPressed: () => Get.dialog(RaiseDisputeDialog(controller: controller)),
        label: Text('+ Raise a Dispute', style: getTextStyle()),
      ),
    );
  }
}
