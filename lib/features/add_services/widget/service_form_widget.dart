import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/features/add_services/controller/add_services_controller.dart';

class ServiceFormWidget extends StatelessWidget {
  final AddServiceController controller;
  final Function(String)? onChanged;
  const ServiceFormWidget(this.controller, {this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            controller.currencyFormatter,
          ],
        ),
      ],
    );
  }

  Widget _buildServiceTypeField() {
    // provide fixed service type options used across the app
    final serviceTypes = ['SOCIAL_POST', 'SERVICE'];

    return DropdownButtonFormField<String>(
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
          .map((t) => DropdownMenuItem<String>(value: t, child: Text(t)))
          .toList(),
      onChanged: (val) {
        controller.selectedServiceType.value = val;
        if (onChanged != null && val != null) onChanged!(val);
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
      onChanged: onChanged,
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
