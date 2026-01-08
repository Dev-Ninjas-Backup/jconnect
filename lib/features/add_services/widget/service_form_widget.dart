import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/features/add_services/controller/add_services_controller.dart';

class ServiceFormWidget extends StatelessWidget {
  final AddServiceController controller;

  const ServiceFormWidget(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller.serviceNameController,
            "Service Name",
            "e.g: Track Review, Promo Collaboration",
          ),
          const SizedBox(height: 16),
          _buildServiceTypeField(),
          const SizedBox(height: 16),
          if (controller.isSocialService.value) ...[
            _buildSocialPlatformField(),
            const SizedBox(height: 16),
          ],
          if (controller.isSocialService.value &&
              controller.selectedLogoPath.value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Center(
                child: Column(
                  children: [
                    const Text(
                      'Selected Platform',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Image.asset(
                      controller.selectedLogoPath.value,
                      height: 40,
                      width: 40,
                    ),
                  ],
                ),
              ),
            ),
          _buildTextField(
            controller.descriptionController,
            "Description",
            "1–2 lines, e.g. 'I'll review your song and share feedback'",
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller.priceController,
            "Price/promotion",
            "\$ Enter Price",
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'^\d*\.?\d{0,2}'),
              ), // allow up to 2 decimals
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTypeField() {
    final serviceTypes = ['SOCIAL_POST', 'SERVICE'];

    return DropdownButtonFormField<String>(
      dropdownColor: AppColors.backGroundColor,
      initialValue: controller.selectedServiceType.value,
      decoration: InputDecoration(
        labelText: 'Service Type',
        labelStyle: getTextStyle(color: AppColors.secondaryTextColor),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.secondaryTextColor),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.redColor),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      items: serviceTypes
          .map(
            (t) => DropdownMenuItem<String>(
              value: t,
              child: Text(
                t,
                style: getTextStyle(color: AppColors.primaryTextColor),
              ),
            ),
          )
          .toList(),
      onChanged: (val) {
        controller.onServiceTypeChanged(val);
      },
    );
  }

  Widget _buildSocialPlatformField() {
    return DropdownButtonFormField<String>(
      dropdownColor: AppColors.backGroundColor,
      initialValue: controller.selectedSocialPlatform.value,
      decoration: InputDecoration(
        labelText: 'Social Platform',
        labelStyle: getTextStyle(color: AppColors.secondaryTextColor),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.secondaryTextColor),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.redColor),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      items: SocialServiceType.values
          .map(
            (e) => DropdownMenuItem<String>(
              value: e.name,
              child: Text(e.name,
                  style: getTextStyle(color: AppColors.primaryTextColor)),
            ),
          )
          .toList(),
      onChanged: (val) {
        controller.onSocialPlatformChanged(val);
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String title,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: getTextStyle(color: AppColors.primaryTextColor),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: title,
        labelStyle: getTextStyle(color: AppColors.secondaryTextColor),
        hintText: hint,
        hintStyle: getTextStyle(color: AppColors.secondaryTextColor),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.secondaryTextColor),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.redColor),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
