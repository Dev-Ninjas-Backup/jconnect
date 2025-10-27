import 'package:flutter/material.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/add_services/controller/add_services_controller.dart';

class ServiceCardWidget extends StatelessWidget {
  final AddServiceController controller;
  final int index;
  const ServiceCardWidget(this.controller, this.index, {super.key});

  @override
  Widget build(BuildContext context) {
    final service = controller.services[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade800),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service['name'] ?? '',
                  style: getTextStyle(
                    color: Colors.white,
                    fontsize: 16,
                    fontweight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  service['desc'] ?? '',
                  style: getTextStyle(color: Colors.white70, fontsize: 13),
                ),
                SizedBox(height: 6),
                Text(
                  service['price'] ?? '',
                  style: getTextStyle(
                    color: Colors.white,
                    fontsize: 14,
                    fontweight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => controller.removeService(index),
            icon: const Icon(Icons.close, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
