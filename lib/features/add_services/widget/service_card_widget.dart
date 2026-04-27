import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/add_services/controller/add_services_controller.dart';

import 'package:jconnect/features/add_services/widget/service_form_widget.dart';

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
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service['name'],
                  style: getTextStyle(
                    color: Colors.white,
                    fontsize: 16,
                    fontweight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  service['desc'],
                  style: getTextStyle(color: Colors.white70, fontsize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  service['price'].toStringAsFixed(0),
                  style: getTextStyle(
                    color: Colors.white,
                    fontsize: 14,
                    fontweight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white70),
                onPressed: () {
                  // ✅ CHANGED: Call startEditingService when tapping edit
                  controller.startEditingService(index);
                  // Open bottom sheet to edit
                  _showEditSheet(context, controller);
                },
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => controller.deleteService(index),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ ADDED: Bottom sheet for editing service
  void _showEditSheet(BuildContext context, AddServiceController controller) {
    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // You can reuse your ServiceFormWidget here
                ServiceFormWidget(
                  controller,
                  //  onChanged: (_) => checkFields(),
                ), // ✅ CHANGED
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          controller.clearForm();
                          Get.back();
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            // controller.isSaveEnabled.value
                            () async {
                              await controller.saveService();
                              Get.back();
                            },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              //controller.isSaveEnabled.value
                              // ? Colors.white70
                              Colors.white70,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Save",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }
}
