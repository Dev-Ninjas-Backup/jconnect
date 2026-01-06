import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/add_services/controller/add_services_controller.dart';
import 'package:jconnect/features/add_services/widget/service_card_widget.dart';
import 'package:jconnect/features/add_services/widget/service_form_widget.dart';
import 'package:jconnect/routes/approute.dart';

class AddServiceScreen extends StatelessWidget {
  const AddServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddServiceController());

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Obx(() {
            final hasServices = controller.services.isNotEmpty;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Show the world what you offer",
                  style: getTextStyle(
                    color: Colors.white,
                    fontsize: 22,
                    fontweight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Add your creative services & get discovered by artists and buyers looking for talent like yours",
                  style: getTextStyle(
                    color: Colors.white70,
                    fontsize: 14,
                    fontweight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Column(
                        children: [
                          if (hasServices)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.services.length,
                              itemBuilder: (context, index) =>
                                  ServiceCardWidget(controller, index),
                            )
                          else
                            ServiceFormWidget(
                              controller,
                              //   onChanged: (_) => controller.checkIfSaveEnabled(),
                            ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(child: SizedBox()),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed:
                                      //controller.isSaveEnabled.value
                                      () async {
                                        await controller.saveService();
                                      },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        //   controller.isSaveEnabled.value
                                        // ? AppColors.redAccent
                                        Colors.white70,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text("Save"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Get.toNamed(AppRoute.navBarScreen);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Colors.white24,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    "Skip for Now",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (hasServices)
                            GestureDetector(
                              onTap: () =>
                                  _showAddServiceSheet(context, controller),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Add More Services",
                                    style: getTextStyle(
                                      color: Colors.white,
                                      fontsize: 15,
                                      fontweight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ✅ CHANGED: Use saveService() instead of addService()
  void _showAddServiceSheet(
    BuildContext context,
    AddServiceController controller,
  ) {
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
                ServiceFormWidget(
                  controller,
                  // onChanged: (_) => checkFields()
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
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
                            //  controller.isSaveEnabled.value
                            () async {
                              await controller.saveService();
                              Get.back();
                            },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Save"),
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
