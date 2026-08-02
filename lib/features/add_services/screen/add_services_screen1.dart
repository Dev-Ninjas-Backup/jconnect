import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/features/add_services/controller/add_services_controller.dart';
import 'package:jconnect/features/add_services/widget/service_card_widget.dart';
import 'package:jconnect/features/add_services/widget/service_form_widget.dart';

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
            // Extract serviceType parameter from arguments
            final Map<dynamic, dynamic>? args = Get.arguments as Map<dynamic, dynamic>?;
            final String? serviceTypeArg = args?['serviceType'];

            // Build a list of indices for services that are NOT custom and match the serviceTypeArg
            final visibleIndices = List<int>.generate(
              controller.services.length,
              (i) => i,
            ).where((i) {
              final svc = controller.services[i];
              if (svc['isCustom'] == true) return false;
              if (serviceTypeArg == null) return true;

              final String? serviceType = svc['serviceType'];
              final socialPlatforms = SocialServiceType.values.map((e) => e.name).toList();
              final isSocial = serviceType == 'SOCIAL_POST' ||
                  (serviceType != null && socialPlatforms.contains(serviceType));

              if (serviceTypeArg == 'SOCIAL_POST') {
                return isSocial;
              } else if (serviceTypeArg == 'SERVICE') {
                return !isSocial;
              }
              return true;
            }).toList();

            final String pageTitle = serviceTypeArg == 'SOCIAL_POST' ? "MY SOCIAL POSTS" : "MY SERVICES";
            final String pageSubtitle = serviceTypeArg == 'SOCIAL_POST'
                ? "Add your social posts & get discovered by artists and buyers looking for promotion"
                : "Add your creative services & get discovered by artists and buyers looking for talent like yours";

            return SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomAppBar2(
                    title: pageTitle,
                    leadingIconUrl: Iconpath.backIcon,
                    onLeadingTap: () => Get.back(),
                  ),
                  SizedBox(height: 20),
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
                    pageSubtitle,
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
                            if (visibleIndices.isNotEmpty)
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: visibleIndices.length,
                                itemBuilder: (context, idx) {
                                  final originalIndex = visibleIndices[idx];
                                  return ServiceCardWidget(
                                    controller,
                                    originalIndex,
                                  );
                                },
                              )
                            else
                              Column(
                                children: [
                                  ServiceFormWidget(controller),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            await controller.saveService();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white70,
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
                                    ],
                                  ),
                                ],
                              ),
                            const SizedBox(height: 16),
                            if (visibleIndices.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  controller.clearForm();
                                  
                                  // Pre-select correct type
                                  if (serviceTypeArg == 'SOCIAL_POST') {
                                    controller.selectedServiceType.value = 'SOCIAL_POST';
                                    controller.isSocialService.value = true;
                                  } else if (serviceTypeArg == 'SERVICE') {
                                    controller.selectedServiceType.value = 'SERVICE';
                                    controller.isSocialService.value = false;
                                  }

                                  showAddServiceSheet(context, controller);
                                },
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
              ),
            );
          }),
        ),
      ),
    );
  }

  void showAddServiceSheet(
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
                        onPressed: () async {
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
