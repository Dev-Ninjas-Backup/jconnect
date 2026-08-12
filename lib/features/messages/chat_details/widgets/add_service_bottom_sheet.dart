import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/widgets/custom_snackbar.dart';
import 'package:jconnect/features/home/request_service/controller/request_service_controller.dart';
import 'package:jconnect/features/messages/controller/custom_service_controller.dart';
import 'package:jconnect/features/messages/controller/messages_controller.dart';
import 'package:jconnect/features/messages/model/chat_conversation_model.dart';
import 'package:jconnect/features/messages/widget/addcustomwidgets.dart';

void showAddServiceSheet(
  BuildContext context,
  AddCustomServiceController controller, {
  required String recipientId,
}) {
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
              CustomServiceFormWidget(
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
                        if (Get.arguments is Map) {
                          Get.arguments['sendInitialServiceRequest'] = false;
                          Get.arguments['initialServiceId'] = null;
                        }

                        final created = await controller.saveService();

                        if (created != null) {
                          final dynamic maybeId =
                              created['id'] ??
                              created['_id'] ??
                              created['serviceId'] ??
                              (created['service'] is Map
                                  ? created['service']['id']
                                  : null);

                          final serviceIdStr = maybeId?.toString();

                          if (recipientId.isNotEmpty &&
                              serviceIdStr != null &&
                              serviceIdStr.isNotEmpty) {
                            try {
                              final reqCtrl =
                                  Get.find<RequestServiceController>();
                              final price =
                                  (created['price'] ?? created['amount'] ?? 0)
                                      .toDouble();
                              final srData = await reqCtrl.submitServiceRequest(
                                serviceId: serviceIdStr,
                                price: price,
                              );
                              final serviceRequestId = srData?['id']
                                  ?.toString();
                              debugPrint(
                                '🔥 [CUSTOM SERVICE] serviceRequestId: $serviceRequestId',
                              );

                              final messagesController =
                                  Get.find<MessagesController>();

                              // Apply service request info to cache so
                              // isPaid (and other fields) are available in
                              // the chat message card, even if the backend
                              // doesn't embed serviceRequest in the send-
                              // message response for custom services.
                              if (srData != null) {
                                final srId = srData['id']?.toString() ?? '';
                                if (srId.isNotEmpty) {
                                  messagesController.applyServiceRequest(
                                    srId,
                                    ServiceRequestInfo.fromJson(srData),
                                  );
                                }
                              }

                              messagesController.sendMessage(
                                recipientId: recipientId,
                                content: '',
                                serviceId: serviceIdStr,
                                serviceRequestId:
                                    serviceRequestId?.isNotEmpty == true
                                        ? serviceRequestId
                                        : null,
                              );
                              Get.back();
                              showGradientSnackBar(
                                title: 'Success',
                                message: 'Service sent',
                              );
                            } catch (e) {
                              Get.back();
                              showGradientSnackBar(
                                title: 'Error',
                                message: 'Failed to send service',
                              );
                            }
                          } else {
                            Get.back();
                            showGradientSnackBar(
                              title: 'Info',
                              message:
                                  'Service creation issue. Please try again.',
                            );
                          }
                        } else {
                          Get.back();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Send"),
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
