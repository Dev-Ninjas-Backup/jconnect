import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';

class CustomObsecureTextfield extends StatelessWidget {
  const CustomObsecureTextfield({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomObsecureTextfieldController());

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryTextColor),
      ),
      child: Obx(() {
        return TextField(
          obscureText: controller.isObscure.value,
          style: getTextStyle(color: AppColors.secondaryTextColor),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            hintText: 'Enter your password',
            hintStyle: getTextStyle(color: AppColors.secondaryTextColor),
            suffixIcon: IconButton(
              icon: Icon(
                controller.isObscure.value
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: Colors.white70,
              ),
              onPressed: controller.toggle,
            ),
          ),
        );
      }),
    );
  }
}

class CustomObsecureTextfieldController extends GetxController {
  final isObscure = true.obs;

  void toggle() => isObscure.value = !isObscure.value;
}
